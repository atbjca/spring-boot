#!/usr/bin/env python3

"""Audit every Maven coordinate in Spring Boot's generated resolved BOM."""

from __future__ import annotations

import argparse
import datetime as dt
import email.utils
import json
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any


OSV_BATCH_URL = "https://api.osv.dev/v1/querybatch"
ALLOWED_CLASSIFICATIONS = {
    "affected",
    "fixed",
    "immune",
    "not_applicable",
    "false_positive",
    "deferred",
}


class AuditFailure(RuntimeError):
    """Raised when an audit cannot produce complete evidence."""


def _utc_now() -> dt.datetime:
    return dt.datetime.now(dt.timezone.utc)


def _isoformat(value: dt.datetime) -> str:
    return value.astimezone(dt.timezone.utc).isoformat().replace("+00:00", "Z")


def _parse_timestamp(value: str) -> dt.datetime:
    parsed = dt.datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=dt.timezone.utc)
    return parsed.astimezone(dt.timezone.utc)


def _encode(value: str) -> str:
    return urllib.parse.quote(value, safe="._~-")


def maven_purl(coordinate: dict[str, str], include_classifier: bool = True) -> str:
    group_id = _encode(coordinate["groupId"])
    artifact_id = _encode(coordinate["artifactId"])
    version = _encode(coordinate["version"])
    purl = f"pkg:maven/{group_id}/{artifact_id}@{version}"
    classifier = coordinate.get("classifier")
    if include_classifier and classifier:
        purl += "?" + urllib.parse.urlencode({"classifier": classifier})
    return purl


def _coordinate_key(coordinate: dict[str, str]) -> tuple[str, str, str, str]:
    return (
        coordinate["groupId"],
        coordinate["artifactId"],
        coordinate["version"],
        coordinate.get("classifier", ""),
    )


def _validate_coordinate(value: Any, source: str) -> tuple[dict[str, str] | None, str | None]:
    if not isinstance(value, dict):
        return None, f"{source}: coordinate is not an object"
    coordinate: dict[str, str] = {}
    for field in ("groupId", "artifactId", "version"):
        item = value.get(field)
        if not isinstance(item, str) or not item.strip():
            return None, f"{source}: missing or invalid {field}"
        coordinate[field] = item
    classifier = value.get("classifier")
    if classifier is not None:
        if not isinstance(classifier, str) or not classifier.strip():
            return None, f"{source}: invalid classifier"
        coordinate["classifier"] = classifier
    return coordinate, None


def build_inventory(bom: dict[str, Any]) -> dict[str, Any]:
    inventory: dict[tuple[str, str, str, str], dict[str, Any]] = {}
    errors: list[str] = []
    input_count = 0
    for library_index, library in enumerate(bom.get("libraries", [])):
        library_name = library.get("name", f"library-{library_index}")
        for dependency_index, dependency in enumerate(library.get("managedDependencies") or []):
            input_count += 1
            source = f"library:{library_name}:managedDependencies[{dependency_index}]"
            coordinate, error = _validate_coordinate(dependency, source)
            if error:
                errors.append(error)
                continue
            _add_inventory_entry(inventory, coordinate, source)
        for bom_index, imported_bom in enumerate(library.get("importedBoms") or []):
            imported_id = imported_bom.get("id") or {}
            imported_name = ":".join(
                str(imported_id.get(field, "?")) for field in ("groupId", "artifactId", "version")
            )
            for dependency_index, dependency in enumerate(imported_bom.get("managedDependencies") or []):
                input_count += 1
                source = (
                    f"library:{library_name}:importedBoms[{bom_index}]({imported_name})"
                    f":managedDependencies[{dependency_index}]"
                )
                coordinate, error = _validate_coordinate(dependency, source)
                if error:
                    errors.append(error)
                    continue
                _add_inventory_entry(inventory, coordinate, source)
    components = sorted(inventory.values(), key=lambda item: item["purl"])
    occurrence_count = sum(len(component["sources"]) for component in components)
    malformed_count = len(errors)
    reconciled = input_count == occurrence_count + malformed_count
    if not reconciled:
        errors.append(
            "inventory count mismatch: "
            f"input={input_count}, emittedOccurrences={occurrence_count}, malformed={malformed_count}"
        )
    return {
        "duplicatePolicy": "groupId, artifactId, version, and classifier form a distinct coordinate; all source occurrences are retained",
        "inputCoordinateCount": input_count,
        "distinctCoordinateCount": len(components),
        "duplicateOccurrenceCount": occurrence_count - len(components),
        "malformedCoordinateCount": malformed_count,
        "reconciled": reconciled and not errors,
        "errors": errors,
        "components": components,
    }


def _add_inventory_entry(
    inventory: dict[tuple[str, str, str, str], dict[str, Any]], coordinate: dict[str, str], source: str
) -> None:
    key = _coordinate_key(coordinate)
    entry = inventory.setdefault(
        key,
        {
            "coordinate": coordinate,
            "purl": maven_purl(coordinate),
            "lookupPurl": maven_purl(coordinate, include_classifier=False),
            "sources": [],
            "upstreamAliases": [],
        },
    )
    entry["sources"].append(source)


def load_aliases(path: Path) -> dict[str, Any]:
    manifest = json.loads(path.read_text(encoding="utf-8"))
    if manifest.get("schemaVersion") != 1 or not isinstance(manifest.get("rules"), list):
        raise AuditFailure(f"invalid alias manifest: {path}")
    return manifest


def apply_aliases(inventory: dict[str, Any], manifest: dict[str, Any]) -> None:
    for component in inventory["components"]:
        coordinate = component["coordinate"]
        for rule in manifest["rules"]:
            upstream = _apply_alias_rule(coordinate, rule)
            if upstream is None:
                continue
            component["upstreamAliases"].append(
                {
                    "ruleId": rule["id"],
                    "provenance": rule["provenance"],
                    "coordinate": upstream,
                    "purl": maven_purl(upstream),
                    "lookupPurl": maven_purl(upstream, include_classifier=False),
                }
            )


def _apply_alias_rule(coordinate: dict[str, str], rule: dict[str, Any]) -> dict[str, str] | None:
    private = rule["private"]
    if coordinate["groupId"] != private["groupId"]:
        return None
    artifact_id = coordinate["artifactId"]
    if "artifactId" in private:
        if artifact_id != private["artifactId"]:
            return None
        upstream_artifact = rule["upstream"]["artifactId"]
    else:
        prefix = private["artifactPrefix"]
        if not artifact_id.startswith(prefix):
            return None
        upstream_artifact = rule["upstream"]["artifactPrefix"] + artifact_id[len(prefix) :]
    version = coordinate["version"]
    normalization = rule.get("versionNormalization")
    if normalization == "strip-nes-patch-suffix":
        version = re.sub(r"-nes\.patch\.\d+(?:-SNAPSHOT)?$", "", version)
    elif normalization not in (None, "identity"):
        raise AuditFailure(f"unsupported version normalization in rule {rule['id']}: {normalization}")
    upstream = {
        "groupId": rule["upstream"]["groupId"],
        "artifactId": upstream_artifact,
        "version": version,
    }
    if coordinate.get("classifier"):
        upstream["classifier"] = coordinate["classifier"]
    return upstream


def collect_lookup_purls(inventory: dict[str, Any]) -> tuple[list[str], dict[str, list[str]]]:
    usage: dict[str, set[str]] = {}
    for component in inventory["components"]:
        component_id = component["purl"]
        usage.setdefault(component["lookupPurl"], set()).add(component_id)
        for alias in component["upstreamAliases"]:
            usage.setdefault(alias["lookupPurl"], set()).add(component_id)
    purls = sorted(usage)
    return purls, {purl: sorted(component_ids) for purl, component_ids in usage.items()}


def query_osv(
    purls: list[str],
    now: dt.datetime,
    batch_size: int,
    timeout: float,
    max_source_age_hours: int,
) -> tuple[list[dict[str, Any]], list[str], list[str]]:
    results: list[dict[str, Any]] = []
    source_dates: list[str] = []
    errors: list[str] = []
    for offset in range(0, len(purls), batch_size):
        batch = purls[offset : offset + batch_size]
        request_body = json.dumps(
            {"queries": [{"package": {"purl": purl}} for purl in batch]}
        ).encode("utf-8")
        request = urllib.request.Request(
            OSV_BATCH_URL,
            data=request_body,
            headers={"Content-Type": "application/json", "User-Agent": "nes-resolved-bom-audit/1"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=timeout) as response:
                payload = json.loads(response.read().decode("utf-8"))
                source_date = _http_date(response.headers.get("Date"))
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as ex:
            errors.append(f"OSV batch {offset // batch_size + 1} failed: {ex}")
            continue
        batch_results = payload.get("results")
        if not isinstance(batch_results, list) or len(batch_results) != len(batch):
            actual = len(batch_results) if isinstance(batch_results, list) else "missing"
            errors.append(
                f"OSV batch {offset // batch_size + 1} result-count mismatch: expected {len(batch)}, got {actual}"
            )
            continue
        if source_date is None:
            errors.append(f"OSV batch {offset // batch_size + 1} omitted a valid HTTP Date header")
        else:
            source_dates.append(_isoformat(source_date))
            age = now - source_date
            if age > dt.timedelta(hours=max_source_age_hours) or age < -dt.timedelta(minutes=5):
                errors.append(
                    f"OSV batch {offset // batch_size + 1} response timestamp is stale or in the future: "
                    f"{_isoformat(source_date)}"
                )
        for result in batch_results:
            if any(key in result for key in ("next_page_token", "nextPageToken")):
                errors.append(f"OSV batch {offset // batch_size + 1} returned a truncated/paginated result")
        results.extend(batch_results)
    if len(results) != len(purls):
        errors.append(f"OSV aggregate result-count mismatch: expected {len(purls)}, got {len(results)}")
    return results, source_dates, errors


def _http_date(value: str | None) -> dt.datetime | None:
    if not value:
        return None
    try:
        parsed = email.utils.parsedate_to_datetime(value)
    except (TypeError, ValueError):
        return None
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=dt.timezone.utc)
    return parsed.astimezone(dt.timezone.utc)


def load_fixture_response(path: Path, now: dt.datetime, max_source_age_hours: int) -> tuple[list[Any], list[str], list[str]]:
    fixture = json.loads(path.read_text(encoding="utf-8"))
    results = fixture.get("results")
    errors: list[str] = []
    if not isinstance(results, list):
        return [], [], ["fixture response has no results array"]
    source_date_value = fixture.get("sourceDate")
    if not isinstance(source_date_value, str):
        return results, [], ["fixture response has no sourceDate"]
    try:
        source_date = _parse_timestamp(source_date_value)
    except ValueError:
        return results, [], [f"fixture response has invalid sourceDate: {source_date_value}"]
    age = now - source_date
    if age > dt.timedelta(hours=max_source_age_hours) or age < -dt.timedelta(minutes=5):
        errors.append(f"fixture response timestamp is stale or in the future: {_isoformat(source_date)}")
    return results, [_isoformat(source_date)], errors


def load_vex(path: Path) -> dict[str, dict[str, Any]]:
    manifest = json.loads(path.read_text(encoding="utf-8"))
    if manifest.get("schemaVersion") != 1 or not isinstance(manifest.get("decisions"), list):
        raise AuditFailure(f"invalid VEX manifest: {path}")
    decisions: dict[str, dict[str, Any]] = {}
    for decision in manifest["decisions"]:
        status = decision.get("status")
        if status not in ALLOWED_CLASSIFICATIONS:
            raise AuditFailure(f"invalid VEX status for {decision.get('id')}: {status}")
        for required in ("id", "rationale", "authority", "reviewedAt"):
            if not isinstance(decision.get(required), str) or not decision[required].strip():
                raise AuditFailure(f"VEX decision is missing {required}: {decision}")
        decisions[decision["id"]] = decision
    return decisions


def normalize_findings(
    purls: list[str],
    usage: dict[str, list[str]],
    results: list[dict[str, Any]],
    vex: dict[str, dict[str, Any]],
) -> list[dict[str, Any]]:
    findings: dict[str, dict[str, Any]] = {}
    for purl, result in zip(purls, results):
        for vulnerability in result.get("vulns") or []:
            identifiers = {vulnerability.get("id")}
            identifiers.update(vulnerability.get("aliases") or [])
            identifiers.discard(None)
            canonical_id = _canonical_vulnerability_id(identifiers)
            finding = findings.setdefault(
                canonical_id,
                {
                    "id": canonical_id,
                    "aliases": set(),
                    "sourcePurls": set(),
                    "coordinates": set(),
                    "advisoryModified": set(),
                },
            )
            finding["aliases"].update(identifiers)
            finding["sourcePurls"].add(purl)
            finding["coordinates"].update(usage[purl])
            if vulnerability.get("modified"):
                finding["advisoryModified"].add(vulnerability["modified"])
    normalized: list[dict[str, Any]] = []
    for finding in findings.values():
        aliases = sorted(finding["aliases"])
        decision = next((vex[identifier] for identifier in aliases if identifier in vex), None)
        normalized.append(
            {
                "id": finding["id"],
                "aliases": aliases,
                "sourcePurls": sorted(finding["sourcePurls"]),
                "coordinates": sorted(finding["coordinates"]),
                "advisoryModified": sorted(finding["advisoryModified"]),
                "classification": decision,
            }
        )
    return sorted(normalized, key=lambda item: item["id"])


def _canonical_vulnerability_id(identifiers: set[str]) -> str:
    for prefix in ("CVE-", "GHSA-"):
        matching = sorted(identifier for identifier in identifiers if identifier.startswith(prefix))
        if matching:
            return matching[0]
    if not identifiers:
        raise AuditFailure("OSV returned a vulnerability without an id")
    return sorted(identifiers)[0]


def create_report(args: argparse.Namespace) -> dict[str, Any]:
    now = _parse_timestamp(args.now) if args.now else _utc_now()
    bom = json.loads(args.input.read_text(encoding="utf-8"))
    inventory = build_inventory(bom)
    aliases = load_aliases(args.aliases)
    apply_aliases(inventory, aliases)
    purls, usage = collect_lookup_purls(inventory)
    report: dict[str, Any] = {
        "schemaVersion": 1,
        "generatedAt": _isoformat(now),
        "input": str(args.input),
        "bom": bom.get("id"),
        "inventory": inventory,
        "lookup": {
            "mode": "inventory-only" if args.inventory_only else "osv-batch",
            "source": OSV_BATCH_URL,
            "queryCount": len(purls),
            "queriedPurls": purls,
            "sourceDates": [],
            "errors": [],
        },
        "findings": [],
    }
    if args.inventory_only:
        report["complete"] = inventory["reconciled"]
        report["clean"] = None
        report["status"] = "inventory-complete" if report["complete"] else "incomplete"
        return report
    if args.osv_response:
        results, source_dates, lookup_errors = load_fixture_response(
            args.osv_response, now, args.max_source_age_hours
        )
    else:
        results, source_dates, lookup_errors = query_osv(
            purls, now, args.batch_size, args.timeout, args.max_source_age_hours
        )
    if len(results) != len(purls):
        lookup_errors.append(f"lookup result-count mismatch: expected {len(purls)}, got {len(results)}")
    report["lookup"]["sourceDates"] = source_dates
    report["lookup"]["errors"] = sorted(set(lookup_errors))
    if len(results) == len(purls):
        vex = load_vex(args.vex)
        report["findings"] = normalize_findings(purls, usage, results, vex)
    unclassified = sum(1 for finding in report["findings"] if finding["classification"] is None)
    report["unclassifiedFindingCount"] = unclassified
    report["complete"] = (
        inventory["reconciled"]
        and not report["lookup"]["errors"]
        and len(results) == len(purls)
        and unclassified == 0
    )
    accepted_risk = any(
        finding["classification"]
        and finding["classification"]["status"] in {"affected", "deferred"}
        for finding in report["findings"]
    )
    report["clean"] = report["complete"] and not accepted_risk
    if not report["complete"]:
        report["status"] = "incomplete"
    elif accepted_risk:
        report["status"] = "complete-with-known-risk"
    else:
        report["status"] = "complete"
    return report


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        type=Path,
        default=Path("spring-boot-project/spring-boot-dependencies/build/createResolvedBom/resolved-bom.json"),
    )
    parser.add_argument(
        "--aliases",
        type=Path,
        default=Path("scripts/security-audit/nes-upstream-aliases.json"),
    )
    parser.add_argument(
        "--vex",
        type=Path,
        default=Path("scripts/security-audit/vex-decisions.json"),
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("build/reports/security/resolved-bom-osv.json"),
    )
    parser.add_argument("--inventory-only", action="store_true")
    parser.add_argument("--osv-response", type=Path, help="deterministic OSV fixture response")
    parser.add_argument("--now", help="override the current UTC time for deterministic tests")
    parser.add_argument("--batch-size", type=int, default=500)
    parser.add_argument("--timeout", type=float, default=60.0)
    parser.add_argument("--max-source-age-hours", type=int, default=24)
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    try:
        report = create_report(args)
    except (AuditFailure, OSError, json.JSONDecodeError, ValueError) as ex:
        print(f"security audit failed: {ex}", file=sys.stderr)
        return 2
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(
        f"security audit {report['status']}: "
        f"{report['inventory']['distinctCoordinateCount']} coordinates, "
        f"{len(report['findings'])} normalized findings; report={args.output}"
    )
    return 0 if report["complete"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
