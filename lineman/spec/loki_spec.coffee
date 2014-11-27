describe 'LokiJS', ->
  db = null
  collection = null

  beforeEach ->
    db = new loki('db')
    collection = db.addCollection('test')

  it "inserts and finds records by id", ->
    obj = {id: 2}
    obj2 = {id: 5, key: 7}
    collection.insert(obj)
    collection.insert(obj2)
    expect(collection.findOne(id: 2)).toBe obj
    expect(collection.findOne(id: 5)).toBe obj2

