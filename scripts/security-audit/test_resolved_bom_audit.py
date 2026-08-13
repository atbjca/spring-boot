#!/usr/bin/env python3

from __future__ import annotations

import datetime as dt
import importlib.util
import json
import tempfile
import unittest
import urllib.error
from pathlib import Path
from unittest import mock


MODULE_PATH = Path(__file__).with_name("resolved_bom_audit.py")
SPEC = importlib.util.spec_from_file_location("resolved_bom_audit", MODULE_PATH)
assert SPEC and SPEC.loader
AUDIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)


class ResolvedBomAuditTests(unittest.TestCase):

    def test_inventory_deduplicates_coordinates_and_retains_sources(self):
        coordinate = {"groupId": "org.example", "artifactId": "demo", "version": "1.0"}
        inventory = AUDIT.build_inventory(
            {
                "libraries": [
                    {
                        "name": "Direct",
                        "managedDependencies": [coordinate],
                        "importedBoms": [
                            {
                                "id": {
                                    "groupId": "org.example",
                                    "artifactId": "demo-bom",
                                    "version": "1.0",
                                },
                                "managedDependencies": [coordinate],
                            }
                        ],
                    }
                ]
            }
        )
        self.assertEqual(2, inventory["inputCoordinateCount"])
        self.assertEqual(1, inventory["distinctCoordinateCount"])
        self.assertEqual(1, inventory["duplicateOccurrenceCount"])
        self.assertEqual(2, len(inventory["components"][0]["sources"]))
        self.assertTrue(inventory["reconciled"])

    def test_maven_purl_encodes_reserved_characters_and_classifier(self):
        purl = AUDIT.maven_purl(
            {
                "groupId": "org.example space",
                "artifactId": "demo/name",
                "version": "1.0+build",
                "classifier": "linux x86_64",
            }
        )
        self.assertEqual(
            "pkg:maven/org.example%20space/demo%2Fname@1.0%2Bbuild?classifier=linux+x86_64",
            purl,
        )

    def test_representative_fork_aliases_are_normalized(self):
        manifest = json.loads(Path(__file__).with_name("nes-upstream-aliases.json").read_text())
        cases = {
            ("cn.bjca.footstone.bpring.boot", "bjca-footstone-bpring-boot-core", "3.5.15-nes.patch.2-SNAPSHOT"):
                ("org.springframework.boot", "spring-boot-core", "3.5.15"),
            ("cn.bjca.footstone.bpring", "bjca-footstone-bpring-context", "6.2.19-nes.patch.1"):
                ("org.springframework", "spring-context", "6.2.19"),
            ("cn.bjca.footstone.bpring.security", "bjca-footstone-bpring-security-core", "6.5.11-nes.patch.2-SNAPSHOT"):
                ("org.springframework.security", "spring-security-core", "6.5.11"),
            ("cn.bjca.footstone.bpring.data", "bjca-footstone-bpring-data-redis", "3.5.13-nes.patch.1"):
                ("org.springframework.data", "spring-data-redis", "3.5.13"),
            ("cn.bjca.footstone.bpring.kafka", "bjca-footstone-bpring-kafka", "3.3.16-nes.patch.1"):
                ("org.springframework.kafka", "spring-kafka", "3.3.16"),
        }
        for private, expected in cases.items():
            inventory = AUDIT.build_inventory(
                {
                    "libraries": [
                        {
                            "name": "fixture",
                            "managedDependencies": [
                                {"groupId": private[0], "artifactId": private[1], "version": private[2]}
                            ],
                        }
                    ]
                }
            )
            AUDIT.apply_aliases(inventory, manifest)
            aliases = inventory["components"][0]["upstreamAliases"]
            self.assertEqual(1, len(aliases), private)
            actual = aliases[0]["coordinate"]
            self.assertEqual(expected, (actual["groupId"], actual["artifactId"], actual["version"]))

    def test_aliases_are_deduplicated_to_cve_and_retain_ghsa(self):
        findings = AUDIT.normalize_findings(
            ["pkg:maven/org.example/demo@1"],
            {"pkg:maven/org.example/demo@1": ["pkg:maven/org.example/demo@1"]},
            [
                {
                    "vulns": [
                        {
                            "id": "GHSA-aaaa-bbbb-cccc",
                            "aliases": ["CVE-2026-0001"],
                            "modified": "2026-08-11T00:00:00Z",
                        },
                        {
                            "id": "CVE-2026-0001",
                            "aliases": ["GHSA-aaaa-bbbb-cccc"],
                            "modified": "2026-08-11T00:00:00Z",
                        },
                    ]
                }
            ],
            {
                "CVE-2026-0001": {
                    "id": "CVE-2026-0001",
                    "status": "fixed",
                    "rationale": "fixture",
                    "authority": "fixture",
                    "reviewedAt": "2026-08-11T00:00:00Z",
                }
            },
        )
        self.assertEqual(1, len(findings))
        self.assertEqual("CVE-2026-0001", findings[0]["id"])
        self.assertEqual(["CVE-2026-0001", "GHSA-aaaa-bbbb-cccc"], findings[0]["aliases"])
        self.assertEqual("fixed", findings[0]["classification"]["status"])

    def test_log4j_deferred_ledger_is_complete(self):
        decisions = AUDIT.load_vex(Path(__file__).with_name("vex-decisions.json"))
        expected = {
            "GHSA-vc5p-v9hr-52mj",
            "GHSA-6hg6-v5c8-fphq",
            "GHSA-445c-vh5m-36rj",
            "GHSA-h383-gmxw-35v2",
            "GHSA-3pxv-7cmr-fjr4",
            "GHSA-w35j-pv5h-q9q9",
            "CVE-2026-49844",
        }
        self.assertTrue(expected.issubset(decisions))
        self.assertTrue(all(decisions[identifier]["status"] == "deferred" for identifier in expected))

    def test_empty_lookup_is_complete(self):
        results, dates, errors = AUDIT.query_osv(
            [], dt.datetime(2026, 8, 11, tzinfo=dt.timezone.utc), 500, 1, 24
        )
        self.assertEqual([], results)
        self.assertEqual([], dates)
        self.assertEqual([], errors)

    def test_failed_lookup_is_reported(self):
        with mock.patch.object(
            AUDIT.urllib.request,
            "urlopen",
            side_effect=urllib.error.URLError("offline"),
        ):
            results, _, errors = AUDIT.query_osv(
                ["pkg:maven/org.example/demo@1"],
                dt.datetime(2026, 8, 11, tzinfo=dt.timezone.utc),
                500,
                1,
                24,
            )
        self.assertEqual([], results)
        self.assertTrue(any("failed" in error for error in errors))
        self.assertTrue(any("result-count mismatch" in error for error in errors))

    def test_inventory_only_report_does_not_require_online_lookup(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            bom = root / "bom.json"
            aliases = root / "aliases.json"
            vex = root / "vex.json"
            bom.write_text(
                json.dumps(
                    {
                        "id": {"groupId": "org.example", "artifactId": "bom", "version": "1"},
                        "libraries": [
                            {
                                "name": "fixture",
                                "managedDependencies": [
                                    {"groupId": "org.example", "artifactId": "demo", "version": "1"}
                                ],
                            }
                        ],
                    }
                )
            )
            aliases.write_text('{"schemaVersion":1,"rules":[]}')
            vex.write_text('{"schemaVersion":1,"decisions":[]}')
            args = AUDIT.parse_args(
                [
                    "--input",
                    str(bom),
                    "--aliases",
                    str(aliases),
                    "--vex",
                    str(vex),
                    "--inventory-only",
                    "--now",
                    "2026-08-11T00:00:00Z",
                ]
            )
            report = AUDIT.create_report(args)
        self.assertEqual("inventory-complete", report["status"])
        self.assertTrue(report["complete"])
        self.assertIsNone(report["clean"])


if __name__ == "__main__":
    unittest.main()
