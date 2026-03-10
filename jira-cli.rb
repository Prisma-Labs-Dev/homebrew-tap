# typed: false
# frozen_string_literal: true

class JiraCli < Formula
  desc "Agent-first Jira CLI with explicit help, JSON output, and no interactive mode"
  homepage "https://github.com/Prisma-Labs-Dev/jira-cli"
  url "https://github.com/Prisma-Labs-Dev/jira-cli/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "9b4739dd2d9be0f3f507fd287c25234f4f31442ea713adb440b6a304a364df17"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", "-o", bin/"jira", "."
  end

  test do
    assert_match "agent-first Jira CLI", shell_output("#{bin}/jira --help")
  end
end
