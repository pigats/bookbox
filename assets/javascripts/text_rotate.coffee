class window.TextRotate

  constructor:  (@el, @items, @interval = 1000) ->
                  @i = 0
                  return this

  next:         ->
                  if (++@i is @items.length) 
                    @i = 0

                  @el.fadeOut( => 
                    @el.text(@items[@i]).fadeIn()
                  )

  cycle:        -> 
                  window.setInterval( => 
                    this.next()
                  , @interval)






