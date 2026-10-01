class Mockingbird < Formula
  desc "Local voice dictation for macOS: hold Fn, speak, and get clean text"
  homepage "https://github.com/NirjharBhattacharjee/mockingbird"
  url "https://github.com/NirjharBhattacharjee/mockingbird/releases/download/v0.1.0/mockingbird-0.1.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

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
    # MOCKINGBIRD_ROOT is the unversioned opt path: Bun resolves symlinks, so
    # without it the launch agent would name this version's Cellar folder,
    # which the next brew upgrade deletes.
    (bin/"mockingbird").write <<~SH
      #!/bin/sh
      MOCKINGBIRD_ROOT="#{opt_libexec}" exec "#{formula_opt_bin("bun")}/bun" "#{opt_libexec}/apps/daemon/src/cli.ts" "$@"
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
