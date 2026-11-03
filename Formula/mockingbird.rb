class Mockingbird < Formula
  desc "Local video editing engine for AI agents: transcribe, cut, caption and render"
  homepage "https://github.com/NirjharBhattacharjee/mockingbird"
  url "https://github.com/NirjharBhattacharjee/mockingbird/releases/download/v0.4.2/mockingbird-0.4.2.tar.gz"
  sha256 "7037c15ec7b91fe9055abec651495c73257008962d8ae928584eb749b45f97e2"
  license "MIT"

  depends_on "go" => :build
  depends_on arch: :arm64
  depends_on "bun"
  depends_on "ffmpeg"
  depends_on :macos
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
                                           output:  libexec/"apps/cli/mockingbird")
      end
      command = "\"#{opt_libexec}/apps/cli/mockingbird\""
    end
    # MOCKINGBIRD_ROOT is the unversioned opt path: Bun resolves symlinks, so
    # without it paths it saves would name this version's Cellar folder, which
    # the next brew upgrade deletes. The Go command finds bun on the PATH.
    (bin/"mockingbird").write <<~SH
      #!/bin/sh
      export MOCKINGBIRD_ROOT="#{opt_libexec}"
      export PATH="#{formula_opt_bin("bun")}:$PATH"
      exec #{command} "$@"
    SH
  end

  def caveats
    <<~EOS
      Download the speech models (about 1 GB, once):
        mockingbird models pull
      Then give it to your AI agent. For Claude Code:
        claude mcp add mockingbird -- mockingbird mcp

      Dictation is gone since 0.4.0. If you used it, log out and back in once:
      its background agent removes itself and gives the Fn key back.
    EOS
  end

  test do
    assert_match "Usage: mockingbird", shell_output("#{bin}/mockingbird --help")
  end
end
