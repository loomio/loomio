<html>
  <head>
    <title>Update site from: GitHub master</title>
  </head>
<body>
<?php `echo ================================== >> gitFetchSite.log`; ?>
<?php `date >> gitFetchSite.log`; ?>
  <pre><?php echo `date`; ?></pre>
  <pre><?php echo `git fetch origin`; ?></pre>
  <pre><?php echo `git checkout origin/master -f`; ?></pre>
  <pre><?php echo `git status`; ?></pre>
  <pre><?php echo `git log -n1`; ?></pre>
  <?php `git log -n1 >> gitFetchSite.log`; ?>
</body>
</html>
