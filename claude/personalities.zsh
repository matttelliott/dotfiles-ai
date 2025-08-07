# Claude Personality Functions
# These functions provide different Claude "modes" for specific tasks
# Each personality has different temperature and system prompts

# Load settings if available
CLAUDE_CONFIG_DIR="${HOME}/.dotfiles-ai/claude/config"
CLAUDE_SETTINGS_FILE="${CLAUDE_CONFIG_DIR}/settings.json"

# Coder - Write production code
claude-coder() {
    local prompt="$*"
    echo "🔧 Claude Coder Mode (temp: 0.3)"
    claude ask "$prompt" \
        --system "You are an expert programmer. Be concise, write clean code, handle errors properly. Follow TDD approach, write tests first."
}

# Architect - Design systems
claude-architect() {
    local prompt="$*"
    echo "🏗️ Claude Architect Mode (temp: 0.5)"
    claude ask "$prompt" \
        --system "You are a senior software architect. Focus on scalability, maintainability, and best practices. Consider trade-offs and provide architectural decisions."
}

# Reviewer - Review code
claude-reviewer() {
    local prompt="$*"
    echo "🔍 Claude Reviewer Mode (temp: 0.2)"
    claude ask "$prompt" \
        --system "You are a meticulous code reviewer. Find bugs, security issues, and suggest improvements. Be thorough but constructive."
}

# Teacher - Explain concepts
claude-teacher() {
    local prompt="$*"
    echo "📚 Claude Teacher Mode (temp: 0.6)"
    claude ask "$prompt" \
        --system "You are a patient teacher. Explain concepts clearly with examples. Break down complex topics into understandable parts."
}

# Creative - Brainstorm solutions
claude-creative() {
    local prompt="$*"
    echo "💡 Claude Creative Mode (temp: 0.9)"
    claude ask "$prompt" \
        --system "You are a creative problem solver. Think outside the box and suggest innovative solutions. Don't be constrained by conventional approaches."
}

# Tester - Write tests
claude-tester() {
    local prompt="$*"
    echo "🧪 Claude Tester Mode (temp: 0.2)"
    claude ask "$prompt" \
        --system "You are a QA engineer. Write comprehensive tests, think of edge cases, ensure full coverage. Include unit, integration, and e2e tests as appropriate."
}

# Debugger - Fix bugs
claude-debugger() {
    local prompt="$*"
    echo "🐛 Claude Debugger Mode (temp: 0.1)"
    claude ask "$prompt" \
        --system "You are a debugging expert. Systematically identify issues, trace execution, and fix bugs. Provide step-by-step debugging approach."
}

# Refactorer - Improve code
claude-refactorer() {
    local prompt="$*"
    echo "♻️ Claude Refactorer Mode (temp: 0.4)"
    claude ask "$prompt" \
        --system "You are a refactoring specialist. Improve code readability, reduce complexity, and enhance maintainability without changing functionality."
}

# Documenter - Write documentation
claude-documenter() {
    local prompt="$*"
    echo "📝 Claude Documenter Mode (temp: 0.5)"
    claude ask "$prompt" \
        --system "You are a technical writer. Create clear, comprehensive documentation with examples. Include usage, API references, and best practices."
}

# Helper function to list all personalities
claude-personalities() {
    echo "Available Claude Personalities:"
    echo "  claude-coder      - Write production code (temp: 0.3)"
    echo "  claude-architect  - Design systems and architecture (temp: 0.5)"
    echo "  claude-reviewer   - Review code for issues (temp: 0.2)"
    echo "  claude-teacher    - Explain concepts clearly (temp: 0.6)"
    echo "  claude-creative   - Brainstorm creative solutions (temp: 0.9)"
    echo "  claude-tester     - Write comprehensive tests (temp: 0.2)"
    echo "  claude-debugger   - Find and fix bugs (temp: 0.1)"
    echo "  claude-refactorer - Improve code structure (temp: 0.4)"
    echo "  claude-documenter - Write documentation (temp: 0.5)"
}