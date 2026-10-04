cask "context-lens" do
  version "0.1.0"
  sha256 "8f39c49e0dad46d5791e0e36acfdd9d578fbb3925a1b8518949e749a221edd97"

  url "https://github.com/Prisma-Labs-Dev/context-lens/releases/download/v#{version}/context-lens-#{version}.zip"
  name "Context Lens"
  desc "Shows what Claude Code and Codex put into their context"
  homepage "https://github.com/Prisma-Labs-Dev/context-lens"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :tahoe

  app "Context Lens.app"
  binary "#{appdir}/Context Lens.app/Contents/MacOS/context-lens"

  uninstall quit: "com.prismalabs.contextlens"

  zap trash: [
    "~/.context-lens",
    "~/Library/Preferences/com.prismalabs.contextlens.plist",
  ]
end
