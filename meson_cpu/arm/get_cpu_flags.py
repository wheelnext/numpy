#!/usr/bin/env python3

import argparse

from provider_variant_aarch64.plugin import AArch64Plugin


def main() -> None:
    argp = argparse.ArgumentParser()
    argp.add_argument("--language", required=True)
    argp.add_argument("--compiler-name", required=True)
    argp.add_argument("--compiler-version", required=True)
    argp.add_argument("--variant", required=True)

    args = argp.parse_args()
    plugin = AArch64Plugin()
    vprops = [
        argparse.Namespace(
            namespace="aarch64",
            feature="version",
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
