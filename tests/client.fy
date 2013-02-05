FancySpec describe: Redis Client with: {
  before_each: {
    @r = Redis Client new
  }

  it: "performs a correct call" with: 'call: when: {
    @r call: ['get, 'foo] . is: nil
    @r call: ['set, 'foo, "bar"] . is: "OK"
    @r call: ['get, 'foo] . is: "bar"
    @r call: ['del, 'foo] . is: 1
    @r call: ['del, 'foo] . is: 0
  }

  it: "performs the transaction correctly" with: 'transaction: when: {
    @r transaction: @{
      call: ['get, 'foo] . is: "QUEUED"
      call: ['set, 'foo, "bar"] . is: "QUEUED"
      call: ['get, 'foo] . is: "QUEUED"
    }
    @r call: ['get, 'foo] . is: "bar"
    @r call: ['del, 'foo] . is: 1
  }
  it: "discards a transaction when an Exception is raised" with: 'transaction: when: {
    @r call: ['get, 'foo] . is: nil
    {
      @r transaction: @{
        call: ['get, 'foo] . is: "QUEUED"
        2 / 0 # raise an error
        call: ['set, 'foo, "bar"] . is: "QUEUED"
      }
    } raises: ZeroDivisionError

    # did not save due to Exception:
    @r call: ['get, 'foo] . is: nil
  }
}