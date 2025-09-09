/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("jzvmv9feg20w7k0")

  // update field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "number2376035640",
    "max": null,
    "min": 100,
    "name": "day_id",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("jzvmv9feg20w7k0")

  // update field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "number2376035640",
    "max": null,
    "min": 100,
    "name": "daily_id",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
})
