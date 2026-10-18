class Mockingbird < Formula
  desc "Local voice dictation for macOS: hold Fn, speak, and get clean text"
  homepage "https://github.com/NirjharBhattacharjee/mockingbird"
  url "https://github.com/NirjharBhattacharjee/mockingbird/releases/download/v0.2.3/mockingbird-0.2.3.tar.gz"
  sha256 "ecab7458a96b4ec15fb359e74830a0b222284a09b99515a1f04cdcbae51cff7f"
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
                                           output:  libexec/"apps/cli/mockingbird")
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
