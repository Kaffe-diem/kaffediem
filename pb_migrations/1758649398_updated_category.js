/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("s6q4j5bzs2tt8yq")

  // update field
  collection.fields.addAt(4, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_608092820",
    "hidden": false,
    "id": "relation2254785150",
    "maxSelect": 999,
    "minSelect": 0,
    "name": "valid_customizations",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("s6q4j5bzs2tt8yq")

  // update field
  collection.fields.addAt(4, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_608092820",
    "hidden": false,
    "id": "relation2254785150",
    "maxSelect": 999,
    "minSelect": 0,
    "name": "customization_keys",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
})
