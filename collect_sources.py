#!/usr/bin/env python3
"""
collect_sources.py

Usage examples (from project root):
  # collect all .gd files into all_gd_files.txt
  python3 collect_sources.py --ext gd

  # collect all .tscn files into all_tscn_files.txt
  python3 collect_sources.py --ext tscn

  # collect both into separate files
  python3 collect_sources.py --ext all

  # collect both into a single combined file
  python3 collect_sources.py --ext all --combined combined_sources.txt

  # preview what would be collected without writing files
  python3 collect_sources.py --ext gd --dry-run

Output files default to:
  all_gd_files.txt
  all_tscn_files.txt
or as specified with --combined / --outdir
"""
from __future__ import annotations
import argparse
import os
import sys
from pathlib import Path
from datetime import datetime

SEPARATOR = "\n" + "="*80 + "\n"

def find_files(root: Path, exts: list[str]) -> list[Path]:
    matches = []
    for dirpath, dirnames, filenames in os.walk(root):
        # skip hidden .git and .godot/editor caches optionally
        # keep everything by default (user wanted all .gd files)
        for fn in filenames:
            for ext in exts:
                if fn.lower().endswith("." + ext.lower()):
                    matches.append(Path(dirpath) / fn)
                    break
    matches.sort()
    return matches

def write_collect(paths: list[Path], out_path: Path, root: Path) -> None:
    header = f"# Collected {len(paths)} files\n# Root: {root}\n# Generated: {datetime.utcnow().isoformat()}Z\n"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8", errors="replace") as f:
        f.write(header)
        for p in paths:
            rel = p.relative_to(root)
            f.write(SEPARATOR)
            f.write(f"# File: {rel}\n")
            f.write(SEPARATOR)
            # Read safely with fallback for weird encodings
            try:
                text = p.read_text(encoding="utf-8")
            except Exception:
                # fallback: binary read and decode with replacement
                text = p.read_bytes().decode("utf-8", errors="replace")
            f.write(text)
            f.write("\n")  # ensure newline after file

def main():
    parser = argparse.ArgumentParser(description="Collect project sources into a single text file (or files).")
    parser.add_argument("--ext", choices=["gd", "tscn", "all"], default="gd",
                        help="Which extension(s) to collect: gd, tscn, or all (both).")
    parser.add_argument("--outdir", default=".",
                        help="Directory to write the output files into (default: project root).")
    parser.add_argument("--combined", default="",
                        help="Write all selected extensions into one combined file with this filename. If omitted, creates separate files.")
    parser.add_argument("--dry-run", action="store_true",
                        help="Don't write files; just print what would be collected.")
    parser.add_argument("--root", default=".", help="Project root to walk (default: current directory).")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    outdir = Path(args.outdir).resolve()

    exts = []
    if args.ext == "gd":
        exts = ["gd"]
    elif args.ext == "tscn":
        exts = ["tscn"]
    else:
        exts = ["gd", "tscn"]

    found = {}
    total = 0
    for ext in exts:
        paths = find_files(root, [ext])
        found[ext] = paths
        total += len(paths)

    print(f"Project root: {root}")
    for ext, paths in found.items():
        print(f"  .{ext}: {len(paths)} files")

    if args.dry_run:
        print("Dry-run: no files written. Exiting.")
        return

    if args.combined:
        combined_path = outdir / args.combined
        # flatten all paths preserving ext order
        all_paths = []
        for ext in exts:
            all_paths.extend(found[ext])
        write_collect(all_paths, combined_path, root)
        print(f"Wrote combined file: {combined_path} ({sum(len(found[e]) for e in exts)} files)")
    else:
        for ext in exts:
            if ext == "gd":
                filename = outdir / "all_gd_files.txt"
            elif ext == "tscn":
                filename = outdir / "all_tscn_files.txt"
            else:
                filename = outdir / f"all_{ext}_files.txt"
            write_collect(found[ext], filename, root)
            print(f"Wrote {filename} ({len(found[ext])} files)")

if __name__ == "__main__":
    main()