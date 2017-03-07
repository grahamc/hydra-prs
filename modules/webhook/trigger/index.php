<?php

function jobset($number, $description) {
  $e_number = escapeshellarg($number);
  $e_desc = escapeshellarg($description);

  file_put_contents("/tmp/whatever",
    shell_exec("export HYDRA_DBI='dbi:Pg:dbname=hydra;user=hydra;'; /run/current-system/sw/bin/hydra-create-jobset nixos --trigger "
                                    . " --pull-request $e_number"
                                    . " --description $e_desc"
                                    . " 2>&1"
  ));
}

function branch($name, $ref) {
  $e_name = escapeshellarg($name);
  $e_ref = escapeshellarg($ref);

  file_put_contents("/tmp/whatever",
    shell_exec("export HYDRA_DBI='dbi:Pg:dbname=hydra;user=hydra;'; /run/current-system/sw/bin/hydra-create-jobset "
                                    . " nixos $e_name --trigger "
                                    . " --ref $e_ref"
                                    . " 2>&1"
  ));
}

$input = json_decode(file_get_contents('php://input'), true);


if (isset($input['number'])
  && isset($input['action'])
  && isset($input['pull_request'])
  && isset($input['pull_request']['title'])
  && isset($input['pull_request']['state'])
) {


  file_put_contents("/tmp/whatever", var_export($input, true));

  $number = (int)$input['number'];
  $description = $input['pull_request']['title'];

  //jobset($number, $description);
} else {
  file_put_contents("/tmp/whatever", var_export($input, true));
}


?>
OK