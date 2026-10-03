class Mockingbird < Formula
  desc "Local voice dictation for macOS: hold Fn, speak, and get clean text"
  homepage "https://github.com/NirjharBhattacharjee/mockingbird"
  url "https://github.com/NirjharBhattacharjee/mockingbird/releases/download/v0.1.1/mockingbird-0.1.1.tar.gz"
  sha256 "d5d1e04712277760a5c38e77fef43819f4c493ba139e01a7dd83cc4cafe97fb5"
  license "MIT"

  depends_on "go" => :build
  depends_on arch: :arm64
  depends_on "bun"
  depends_on "ffmpeg"
  depends_on :macos
  depends_on "ollama"
  depends_on "whisper.cpp"

  def install
    libexec.install Dir["*"]
    cd libexec do
      system "bun", "install", "--frozen-lockfile", "--production"
    end
    # The Go command with the launch animation, in releases that have apps/cli.
    # Older ones get the TypeScript CLI, as before.
    command = "\"#{formula_opt_bin("bun")}/bun\" \"#{opt_libexec}/apps/daemon/src/cli.ts\""
    if (libexec/"apps/cli").exist?
      cd libexec/"apps/cli" do
        system "go", "build", *std_go_args(ldflags: "-s -w -X main.release=v#{version}",
                                           output: libexec/"apps/cli/mockingbird")
      end
      command = "\"#{opt_libexec}/apps/cli/mockingbird\""
    end
    # MOCKINGBIRD_ROOT is the unversioned opt path: Bun resolves symlinks, so
    # without it the launch agent would name this version's Cellar folder,
    # which the next brew upgrade deletes. The Go command finds bun on the PATH.
    (bin/"mockingbird").write <<~SH
      #!/bin/sh
      export MOCKINGBIRD_ROOT="#{opt_libexec}"
      export PATH="#{formula_opt_bin("bun")}:$PATH"
      exec #{command} "$@"
    SH
  end

  def caveats
    <<~EOS
      Download the speech and cleanup models (a few GB, once):
        mockingbird models pull
      Then run it in the background, now and at every login:
        mockingbird start

      After a brew upgrade, run `mockingbird restart` to use the new version.
    EOS
  end

  test do
    assert_match "Usage: mockingbird", shell_output("#{bin}/mockingbird --help")
  end
end
