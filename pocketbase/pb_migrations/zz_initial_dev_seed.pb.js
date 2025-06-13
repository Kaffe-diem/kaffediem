migrate((app) => {
  if ($os.getenv('POCKETBASE_ENVIRONMENT') !== 'dev') {
    console.log('Skipping dev seed because POCKETBASE_ENVIRONMENT is not dev');
    return;
  }

  try {
    const superuserCollection = app.findCollectionByNameOrId('_superusers');
    const superuser = new Record(superuserCollection);
    superuser.set('email', $os.getenv('PB_TEST_ADMIN_EMAIL'));
    superuser.set('password', $os.getenv('PB_TEST_ADMIN_PASSWORD'));
    app.save(superuser);
    console.log('Created superuser');
  } catch {
    console.warn('Skipping superuser creation, it probably already exists.');
  }

  try {
    const userCollection = app.findCollectionByNameOrId('user');
    const adminUser = new Record(userCollection);
    adminUser.set('email', $os.getenv('PB_TEST_ADMIN_EMAIL'));
    adminUser.set('password', $os.getenv('PB_TEST_ADMIN_PASSWORD'));
    adminUser.set('is_admin', true);
    app.save(adminUser);
    console.log('Created admin user');
  } catch {
    console.warn('Skipping admin user creation, it probably already exists.');
  }
}, (app) => {
  if ($os.getenv('POCKETBASE_ENVIRONMENT') !== 'dev') {
    console.log('Skipping dev seed because POCKETBASE_ENVIRONMENT is not dev');
    return;
  }

  try {
    const superuser = app.findAuthRecordByEmail('_superusers', $os.getenv('PB_ADMIN_EMAIL'));
    app.delete(superuser);
    console.log('Deleted superuser');
  } catch {
    console.warn('Failed to delete superuser');
  }

  try {
    const adminUser = app.findAuthRecordByEmail('user', $os.getenv('PB_TEST_ADMIN_EMAIL'));
    app.delete(adminUser);
    console.log('Deleted admin user');
  } catch {
    console.warn('Failed to delete admin user');
  }
});
