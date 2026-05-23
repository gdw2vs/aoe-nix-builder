{
  description = "Cachix binary cache builder for Agent of Empires";

  inputs = {
    agent-of-empires.url = "github:njbrake/agent-of-empires";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, agent-of-empires, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in {
      packages = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          upstream = agent-of-empires.packages.${system};
          src = agent-of-empires.outPath;

          # The upstream flake.nix sometimes ships with a stale npmDepsHash.
          # Build webFrontend ourselves so we control the hash and the workflow
          # doesn't break every time upstream releases without updating it.
          #
          # Update this hash when web/package-lock.json changes upstream.
          # Get the new value from: nix build .#aoe-with-web 2>&1 | grep 'got:'
          webFrontend = pkgs.buildNpmPackage {
            pname = "agent-of-empires-web";
            version = "0";
            src = "${src}/web";
            npmDepsHash = "sha256-RTL/3DccMZODLr9lMZdQfoMFtK2ZsARFMABh4SUV4xI=";
            installPhase = ''
              mkdir $out
              cp -r dist $out/
            '';
          };
        in
        upstream // {
          aoe-with-web = upstream.aoe-with-web.overrideAttrs (_: {
            AOE_WEB_DIST = "${webFrontend}/dist";
          });
        }
      );

      devShells = agent-of-empires.devShells;
      checks = agent-of-empires.checks;
    };
}
