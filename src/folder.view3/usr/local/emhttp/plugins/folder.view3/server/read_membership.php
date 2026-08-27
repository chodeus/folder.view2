<?php
    require_once("/usr/local/emhttp/plugins/folder.view3/server/lib.php");
    fv3_get_init();
    header('Content-Type: application/json');
    $type = fv3_validate_type($_GET['type'] ?? '');
    // Labels and the autostart tab are Docker concepts — no vm consumer exists
    if ($type !== 'docker') {
        http_response_code(400);
        echo json_encode(['error' => 'membership map is available for type=docker only']);
        exit;
    }
    global $configDir;
    $folders = fv3_read_json_strict("$configDir/docker.json");
    if ($folders === null) {
        http_response_code(500);
        echo json_encode(['error' => 'docker.json is unreadable']);
        exit;
    }
    $dockerClient = new DockerClient();
    $allContainerNames = fv3_read_container_names($dockerClient)['names'];
    $ctLabels = fv3_read_container_labels($dockerClient, $allContainerNames);
    // Fail closed — the client keeps its explicit-only fallback rather than render half a map
    if ($ctLabels === null) {
        http_response_code(503);
        echo json_encode(['error' => 'container label read unavailable']);
        exit;
    }
    $m = fv3_compute_folder_membership($folders, $allContainerNames, $ctLabels);
    if ($m === null) {
        http_response_code(500);
        echo json_encode(['error' => 'folder config contains an invalid containers shape']);
        exit;
    }
    $out = [];
    foreach ($m['containers'] as $placeholder => $members) {
        foreach ($members as $ct) { $out[$ct] = $m['names'][$placeholder]; }
    }
    echo json_encode(['membership' => (object)$out]);
?>
