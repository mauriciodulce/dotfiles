<?php

use function Laravel\Prompts\search;

require __DIR__.'/../../.composer/vendor/autoload.php';

$package = $argv[1] ?? null;

$projects = collect(scandir('/Users/mauriciodulce/Code'))
    ->flatMap(fn (string $directory) => glob("/Users/mauriciodulce/Code/{$directory}" . '/*', GLOB_ONLYDIR))
    ->reject(fn (string $directory) => ! file_exists("{$directory}/composer.json"))
    ->filter(function (string $directory) {
        $composerJson = json_decode(file_get_contents("{$directory}/composer.json"), true);
        return isset($composerJson['name']) && ! in_array($composerJson['name'], ['laravel/laravel', 'statamic/statamic']);
    })
    ->mapWithKeys(function (string $directory) {
        $composerJson = json_decode(file_get_contents("{$directory}/composer.json"), true);
        return [$directory => $composerJson['name']];
    });

// Definir $recommended como todos los proyectos encontrados
$recommended = $projects->all();

// Cuando se proporciona un paquete como argumento, omitimos la búsqueda.
if ($package) {
    $project = $projects->flip()->get($package);
} else {
    $project = search(
        label: 'Which project would you like to symlink?',
        options: fn (string $value) => strlen($value) > 0
            ? $projects->filter(fn ($project) => str_contains($project, $value))->all()
            : $recommended, // Ahora esta variable está definida
    );
}

// Validar que se encontró un proyecto antes de continuar
if (!$project) {
    fwrite(STDERR, "❌ Error: No project selected.\n");
    exit(1);
}

$composerJson = json_decode(file_get_contents("{$project}/composer.json"), true);
$vendorName = explode('/', $composerJson['name'])[0] ?? 'unknown';
$packageName = explode('/', $composerJson['name'])[1] ?? 'unknown';

file_put_contents('/tmp/project-symlinking.txt', "{$project}|{$vendorName}|{$packageName}");
