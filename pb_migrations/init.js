migrate(
  (app) => {
    const superusers = app.findCollectionByNameOrId("_superusers");
    const users = app.findCollectionByNameOrId("user");

    if (process.env.POCKETBASE_ENVIRONMENT == "dev") {
      const createRecord = (collection, data) => {
        let record = new Record(collection);
        Object.entries(data).forEach(([key, value]) => record.set(key, value));
        app.save(record);
      };

      const password = process.env.PB_TEST_PASSWORD;

      createRecord(superusers, {
        email: process.env.PB_TEST_ADMIN_EMAIL,
        password
      });

      createRecord(users, {
        email: process.env.PB_TEST_USER_EMAIL,
        password,
        verified: true,
        is_admin: false
      });

      createRecord(users, {
        email: process.env.PB_TEST_ADMIN_EMAIL,
        password,
        verified: true,
        is_admin: true
      });
    }
  },
  (app) => {
    const superusers = app.findCollectionByNameOrId("_superusers");
    const users = app.findCollectionByNameOrId("user");

    const safeDelete = (collection, email) => {
      try {
        const record = app.findAuthRecordByEmail(collection, email);
        if (record) app.delete(record);
      } catch (e) {
        console.log(`Could not delete ${email}:`, e);
      }
    };

    safeDelete(superusers, process.env.PB_TEST_ADMIN_EMAIL);
    safeDelete(users, process.env.PB_TEST_USER_EMAIL);
    safeDelete(users, process.env.PB_TEST_ADMIN_EMAIL);
  }
);
