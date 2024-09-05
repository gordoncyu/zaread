{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f { 
        pkgs = import nixpkgs { inherit system; };
        }
      );
    in {
      packages = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.stdenv.mkDerivation rec {
          name = "zaread";
          src = self;
          outputs = [ "out" ];

          nativeBuildInputs = with pkgs; [ pkgs.makeWrapper ];
          buildInputs = with pkgs; [ libreoffice calibre md2pdf file ];

          preConfigurePhases = ''
          setDest
          '';

          setDest = ''
          mkdir -p $out/bin
          mkdir -p $out/share
          export DEST=$out
          '';

          postFixup = with pkgs; ''
            wrapProgram $out/bin/zaread \
              --set PATH ${lib.makeBinPath [
              libreoffice calibre md2pdf file zathura coreutils gnused
              ]}
          '';

          meta = with pkgs.lib; {
            homepage = "https://github.com/paoloap/zaread";
            license = with licenses; [ gpl3Only ];
          };
        };
      });
    };
}
