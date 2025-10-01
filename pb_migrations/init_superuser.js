migrate((app) => {
    let superusers = app.findCollectionByNameOrId("_superusers")

    if (process.env.NODE_ENV == "development") {
      let record = new Record(superusers)

      record.set("email", process.env.PB_TEST_ADMIN_EMAIL)
      record.set("password", process.env.PB_TEST_ADMIN_PASSWORD)

      app.save(record)
    }
}, (app) => {
    try {
        let record = app.findAuthRecordByEmail("_superusers", process.env.PB_TEST_ADMIN_EMAIL)
        app.delete(record)
    } catch {
    }
})
