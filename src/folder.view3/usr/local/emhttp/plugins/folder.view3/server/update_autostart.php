<?php
    require_once("/usr/local/emhttp/plugins/folder.view3/server/lib.php");
    fv3_post_init();
    header('Content-Type: application/json');
    $mode = $_POST['mode'] ?? '';
    $sequence = json_decode($_POST['sequence'] ?? '[]', true);
    $waits = json_decode($_POST['waits'] ?? '{}', true);
    if (!is_array($sequence) || !is_array($waits)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid payload']);
        exit;
    }
    $result = updateAutostartConfig($mode, $sequence, $waits);
    if (isset($result['error'])) http_response_code(400);
    echo json_encode($result);
?>
