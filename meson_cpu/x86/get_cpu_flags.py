#!/usr/bin/env python3

import argparse

from provider_variant_x86_64.plugin import X8664Plugin


def main() -> None:
    argp = argparse.ArgumentParser()
    argp.add_argument("--language", required=True)
    argp.add_argument("--compiler-name", required=True)
    argp.add_argument("--compiler-version", required=True)
    argp.add_argument("--variant", required=True)

    args = argp.parse_args()
    plugin = X8664Plugin()
    vprops = [
        argparse.Namespace(
            namespace="x86_64",
            feature="level",
            value=args.variant,
        )
    ]
    print(
        " ".join(
            plugin.get_compiler_flags(
                args.language, args.compiler_name, args.compiler_version, vprops
            )
        )
    )


if __name__ == "__main__":
    main()
