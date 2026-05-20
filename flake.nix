{
  description = "Cachix binary cache builder for Agent of Empires";

  inputs = {
    agent-of-empires.url = "github:njbrake/agent-of-empires";
  };

  outputs = { self, agent-of-empires, ... }: {
    # Re-export upstream packages so `nix build`, `nix run`, etc. work
    # directly from this flake.
    packages = agent-of-empires.packages;
    devShells = agent-of-empires.devShells;
    checks = agent-of-empires.checks;
  };
}
