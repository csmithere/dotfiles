#!/usr/bin/env python3
"""Salesforce CLI helper — query opportunities by geography, stage, SE lead, or name."""

import argparse
import json
import os
import re
import subprocess
import sys
import textwrap

STAGE_MAP = {
    "0": "0. Qualification",
    "1": "1. Discovery",
    "2": "Consensus / Demo",
    "3": "Proof of Value",
}

COMMAND_STAGES = {
    "pov": "Proof of Value",
    "demo": "Consensus / Demo",
    "qual": "0. Qualification",
    "disco": "1. Discovery",
}

FIELDS = (
    "Name, StageName, SE_Lead__r.Name, "
    "SE_Next_Steps_Last_Updated__c, POV_next_steps__c"
)


def parse_csv_action(option_strings, dest, **kwargs):
    """Argparse action that accumulates comma-separated values into a flat list."""

    class CSVAppend(argparse.Action):
        def __call__(self, parser, namespace, values, option_string=None):
            current = getattr(namespace, self.dest) or []
            for v in values.split(","):
                v = v.strip()
                if v:
                    current.append(v)
            setattr(namespace, self.dest, current)

    return CSVAppend(option_strings, dest, **kwargs)


def build_se_clause(se_list):
    parts = [f"SE_Lead__r.Name LIKE '%{name}%'" for name in se_list]
    return f"({' OR '.join(parts)})"


def build_stage_clause(stage_list):
    parts = []
    for num in stage_list:
        stage_name = STAGE_MAP.get(num)
        if stage_name:
            parts.append(f"StageName LIKE '%{stage_name}%'")
    if not parts:
        sys.exit("Error: no valid stage numbers provided (use 0-3)")
    return f"({' OR '.join(parts)})"


def run_query(query):
    try:
        result = subprocess.run(
            ["sf", "data", "query", "-q", query, "-o", "bigid", "--json"],
            capture_output=True, text=True,
        )
    except FileNotFoundError:
        sys.exit("Error: 'sf' CLI not found. Install it with: npm install -g @salesforce/cli")
    if result.returncode != 0:
        try:
            err = json.loads(result.stdout)
            msg = err.get("message") or err.get("result", {}).get("message") or result.stdout
        except (json.JSONDecodeError, AttributeError):
            msg = result.stderr or result.stdout
        sys.exit(f"Query error: {msg}")
    return json.loads(result.stdout)


def latest_update(text):
    if not text:
        return ""
    text = text.replace("\r", "").strip()
    parts = re.split(r"\n(?=\d{1,2}[/-]\d{1,2}[/-]\d{2,4})", text)
    first = parts[0].replace("\n", " ").strip()
    if len(first) > 255:
        first = first[:252] + "..."
    return first


def format_table(data):
    records = data.get("result", {}).get("records", [])
    if not records:
        print("No records found.")
        return

    rows = []
    for r in records:
        se_lead = (r.get("SE_Lead__r") or {}).get("Name") or ""
        rows.append({
            "Name": r.get("Name") or "",
            "Stage": r.get("StageName") or "",
            "SE Lead": se_lead,
            "Updated": r.get("SE_Next_Steps_Last_Updated__c") or "",
            "Latest Next Steps": latest_update(r.get("POV_next_steps__c")),
        })

    cols = ["Name", "Stage", "SE Lead", "Updated", "Latest Next Steps"]

    try:
        term_width = max(os.get_terminal_size().columns, 120)
    except OSError:
        term_width = 120

    overhead = len(cols) + 1 + 2 * len(cols)
    available = term_width - overhead
    fixed = {"Stage": 22, "SE Lead": 20, "Updated": 10}
    flex_budget = available - sum(fixed.values())
    name_w = min(40, max(20, flex_budget * 30 // 100))
    widths = {
        "Name": name_w,
        "Stage": fixed["Stage"],
        "SE Lead": fixed["SE Lead"],
        "Updated": fixed["Updated"],
        "Latest Next Steps": max(20, flex_budget - name_w),
    }

    def wrap_row(row):
        wrapped = {}
        for c in cols:
            val = str(row[c]).replace("\n", " ").replace("\r", "")
            wrapped[c] = textwrap.wrap(val, widths[c]) or [""]
        return wrapped

    def print_sep():
        print("+" + "+".join("-" * (widths[c] + 2) for c in cols) + "+")

    def print_light_sep():
        print("|" + "|".join("-" * (widths[c] + 2) for c in cols) + "|")

    def print_row_lines(wrapped):
        max_lines = max(len(wrapped[c]) for c in cols)
        for i in range(max_lines):
            parts = []
            for c in cols:
                lines = wrapped[c]
                val = lines[i] if i < len(lines) else ""
                parts.append(" " + val.ljust(widths[c]) + " ")
            print("|" + "|".join(parts) + "|")

    print_sep()
    print_row_lines({c: [c] for c in cols})
    print_sep()
    for i, row in enumerate(rows):
        print_row_lines(wrap_row(row))
        if i < len(rows) - 1:
            print_light_sep()
    print_sep()
    print(f"\nTotal records: {len(rows)}")


def format_industry(data, geo_label):
    """Display a percentage breakdown of customer accounts by industry vertical."""
    records = data.get("result", {}).get("records", [])
    if not records:
        print("No records found.")
        return

    total = sum(int(r.get("cnt", 0)) for r in records)
    if total == 0:
        print("No customer accounts with industry data found.")
        return

    try:
        term_width = max(os.get_terminal_size().columns, 80)
    except OSError:
        term_width = 80

    # Size the name column to fit the longest industry name (max 55 chars)
    max_name_len = max(len(r.get("Industry") or "(blank)") for r in records)
    name_col = min(max_name_len, 55)

    # Fixed widths: "  " indent + name + "  " + count(6) + "  " + pct(6) + "  " + bar
    fixed_overhead = 2 + 2 + 6 + 2 + 6 + 2
    bar_max = max(10, min(40, term_width - name_col - fixed_overhead))

    geo_str = f"Geography : {geo_label}" if geo_label else "Geography : All"
    divider = "─" * (name_col + fixed_overhead + bar_max)

    print()
    print(f"  Customer Accounts by Industry Vertical")
    print(f"  {divider}")
    print(f"  {geo_str}   │   Total accounts : {total:,}")
    print(f"  {divider}")
    print()

    # Header row
    print(f"  {'Industry':<{name_col}}  {'Count':>6}  {'Pct':>6}  Bar")
    print(f"  {'─' * name_col}  {'─' * 6}  {'─' * 6}  {'─' * bar_max}")

    for r in records:
        industry = r.get("Industry") or "(blank)"
        # Truncate names that exceed the column width
        if len(industry) > name_col:
            industry = industry[: name_col - 1] + "…"
        count = int(r.get("cnt", 0))
        pct = count / total * 100
        filled = round(pct / 100 * bar_max)
        bar = "█" * filled + "░" * (bar_max - filled)
        print(f"  {industry:<{name_col}}  {count:>6,}  {pct:>5.1f}%  {bar}")

    print()
    print(f"  {divider}")
    print()


def main():
    parser = argparse.ArgumentParser(
        description="Query Salesforce opportunities and account data",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
            commands:
              pov          Proof of Value opportunities
              pov-stale    POVs with no SE update in 7 days
              demo         Consensus / Demo opportunities
              demo-stale   Demos with no SE update in 7 days
              qual         Qualification opportunities
              qual-stale   Qualifications with no SE update in 7 days
              disco        Discovery opportunities
              disco-stale  Discoveries with no SE update in 7 days
              industry     % breakdown of customer accounts by industry vertical
              search       Search opportunities by name
              geo          List available geographies

            examples:
              sfdc --stage 2,3 --se patrick
              sfdc pov --se person1,person2
              sfdc search "acme" --se eicher
              sfdc pov --geo EMEAAPJ
              sfdc demo --geo all
              sfdc industry
              sfdc industry --geo EMEAAPJ
              sfdc industry --geo all
              sfdc geo
        """),
    )
    parser.add_argument(
        "command", nargs="?",
        help="subcommand (pov, demo, qual, disco, industry, search, or add -stale)",
    )
    parser.add_argument(
        "search_term", nargs="?",
        help="search term (only used with 'search' command)",
    )
    parser.add_argument(
        "--se", action=parse_csv_action, default=[],
        metavar="NAME",
        help="filter by SE Lead (comma-separated or repeated)",
    )
    parser.add_argument(
        "--stage", action=parse_csv_action, default=[],
        metavar="N",
        help="filter by stage number: 0=Qual, 1=Disco, 2=Demo, 3=POV",
    )
    parser.add_argument(
        "--geo", default="North America",
        metavar="GEO",
        help="filter by geography (default: 'North America', use 'all' for all geos)",
    )
    args = parser.parse_args()

    # ── geo list ─────────────────────────────────────────────────────────────
    if args.command == "geo":
        query = "SELECT Account.Geo1__c FROM Opportunity WHERE Account.Geo1__c != null LIMIT 2000"
        data = run_query(query)
        records = data.get("result", {}).get("records", [])
        geos = sorted({
            (r.get("Account") or {}).get("Geo1__c")
            for r in records if (r.get("Account") or {}).get("Geo1__c")
        })
        if not geos:
            print("No geographies found.")
        else:
            print("Available geographies:")
            for g in geos:
                print(f"  {g}")
        sys.exit(0)

    # ── industry vertical breakdown ──────────────────────────────────────────
    if args.command == "industry":
        where = ["Type = 'Customer'", "Industry != null"]
        geo_label = None
        if args.geo.lower() != "all":
            where.append(f"Geo1__c = '{args.geo}'")
            geo_label = args.geo
        query = (
            f"SELECT Industry, COUNT(Id) cnt FROM Account "
            f"WHERE {' AND '.join(where)} "
            f"GROUP BY Industry ORDER BY COUNT(Id) DESC"
        )
        data = run_query(query)
        format_industry(data, geo_label)
        sys.exit(0)

    if not args.command and not args.stage:
        parser.print_help()
        sys.exit(1)

    # ── opportunity queries ──────────────────────────────────────────────────
    where = []
    if args.geo.lower() != "all":
        where.append(f"Account.Geo1__c = '{args.geo}'")

    if args.stage:
        where.append(build_stage_clause(args.stage))
    elif args.command:
        base_cmd = args.command.replace("-stale", "")
        if base_cmd == "search":
            if not args.search_term:
                sys.exit("Usage: sfdc search <name> [--se <lead>]")
            where.append(f"Name LIKE '%{args.search_term}%'")
        elif base_cmd in COMMAND_STAGES:
            stage_name = COMMAND_STAGES[base_cmd]
            where.append(f"StageName LIKE '%{stage_name}%'")
        else:
            sys.exit(f"Unknown command: {args.command}\nRun 'sfdc -h' for usage.")

        if args.command.endswith("-stale"):
            where.append(
                "(SE_Next_Steps_Last_Updated__c < LAST_N_DAYS:7 "
                "OR SE_Next_Steps_Last_Updated__c = null)"
            )

    if args.se:
        where.append(build_se_clause(args.se))

    query = f"SELECT {FIELDS} FROM Opportunity WHERE {' AND '.join(where)}"
    data = run_query(query)
    format_table(data)


if __name__ == "__main__":
    main()
