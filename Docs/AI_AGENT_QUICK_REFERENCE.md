# Quick Reference for AI Agents

## 📁 Documentation Organization Rules

### ✅ DO
- Place ALL `.md` files in `/docs` directory
- Update `docs/README.md` when adding/removing files
- Follow naming conventions: `{topic}_guide.md`, `{component}_TESTING_GUIDE.md`
- Categorize using the 7 standard categories
- Remove duplicates and organize systematically

### ❌ DON'T
- Leave `.md` files in project root (except main `README.md`)
- Create documentation in `/lib`, `/android`, `/ios` directories
- Duplicate files between `/docs` and other locations
- Skip updating the documentation index

## 🔧 Quick Commands

### Move all documentation to docs/
```bash
find . -maxdepth 1 -name "*.md" ! -name "README.md" -exec mv {} docs/ \;
```

### Check for stray documentation
```bash
find . -name "*.md" ! -path "./docs/*" ! -name "README.md"
```

### List all documentation
```bash
ls -la docs/*.md
```

## 📋 Standard Categories
1. 🚀 Getting Started
2. 🔧 Setup & Configuration  
3. 🏥 Health Connect Integration
4. 🧪 Testing & Debugging
5. 📊 Development & Maintenance
6. 🏗️ Project Phases
7. 🔒 Security & Configuration

See `DOCUMENTATION_GUIDELINES.md` for complete details.
