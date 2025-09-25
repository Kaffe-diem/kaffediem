/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("nkpj6zphir5jxz0")

  // add field
  collection.fields.addAt(6, new Field({
    "hidden": false,
    "id": "number1169138922",
    "max": null,
    "min": null,
    "name": "sort_order",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("nkpj6zphir5jxz0")

  // remove field
  collection.fields.removeById("number1169138922")

  return app.save(collection)
})
