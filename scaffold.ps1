# Phase 2 scaffold: run from the ROOT of the Flutter project (where pubspec.yaml is).
# Usage: powershell -ExecutionPolicy Bypass -File .\scaffold.ps1
# Safe to re-run: existing files are never overwritten.

if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "pubspec.yaml not found. Run this from the Flutter project root."
    exit 1
}

$features = @(
    "authentication", "dashboard", "curriculum", "lessons", "grammar",
    "vocabulary", "dictionary", "verbs", "reading", "listening", "writing",
    "speaking", "practice", "assignments", "teacher", "progress", "audio",
    "settings"
)

$dirs = @(
    ".github/workflows",
    "assets/images", "assets/icons", "assets/fonts", "assets/audio",
    "lib/core/config", "lib/core/constants", "lib/core/errors",
    "lib/core/logging", "lib/core/routing", "lib/core/theme", "lib/core/utils",
    "lib/data/remote", "lib/data/repositories",
    "lib/shared/models", "lib/shared/widgets", "lib/shared/services",
    "test/core", "test/features", "test/data", "test/widgets",
    "integration_test",
    "supabase/migrations", "supabase/functions", "supabase/seed", "supabase/tests",
    "content/curriculum/a1", "content/curriculum/a2", "content/curriculum/b1",
    "content/curriculum/b2", "content/curriculum/c1", "content/curriculum/c2",
    "content/grammar", "content/vocabulary", "content/verbs", "content/reading",
    "content/listening", "content/writing", "content/exercises",
    "tools/dictionary_importer",
    "docs"
)

foreach ($f in $features) {
    foreach ($layer in @("data", "domain", "presentation")) {
        $dirs += "lib/features/$f/$layer"
    }
}

foreach ($d in $dirs) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
    $keep = Join-Path $d ".gitkeep"
    # Only add .gitkeep to directories that are empty
    if (-not (Get-ChildItem -Force -Path $d | Where-Object { $_.Name -ne ".gitkeep" })) {
        if (-not (Test-Path $keep)) { New-Item -ItemType File -Path $keep | Out-Null }
    }
}

$docs = @{
    "docs/ARCHITECTURE.md" = "# Architecture`n`nFeature-first structure: core, data, shared, features. Riverpod for state, GoRouter for navigation, repositories between UI and data sources.`n"
    "docs/DATABASE.md"     = "# Database`n`nSupabase (PostgreSQL) schema, RLS policies and migrations.`n"
    "docs/CONTENT_FORMAT.md" = "# Content format`n`nFormat and validation rules for files under content/.`n"
    "docs/SECURITY.md"     = "# Security`n`nNever ship a Supabase service-role key or other private secret in the app.`n"
    "docs/TESTING.md"      = "# Testing`n`nUnit, widget, integration and security (RLS) tests.`n"
    "docs/RELEASES.md"     = "# Releases`n`nVersioning, build commands, signing, checklist, rollback and migration procedure.`n"
}
foreach ($path in $docs.Keys) {
    if (-not (Test-Path $path)) {
        Set-Content -Path $path -Value $docs[$path] -Encoding UTF8
    }
}

Write-Host "Scaffold complete. Next: git add . ; git commit -m 'chore: add project structure'"
