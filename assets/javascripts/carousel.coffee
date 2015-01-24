class window.Carousel

  constructor:  (@viewport_el, @list_el, @interval = 5000) ->
                  if @interval < 2000 
                    @interval = 2000
                    console.log "too fast babe! we've slowed the carousel down to 2s"

                  @viewport_el.on('mouseover', (e) => this.pause())
                  @viewport_el.on('mouseleave', => this.next(); this.cycle())
                  @list_el.on('touchstart', (e) => this.pause(); return false unless e.target.tagName.toLowerCase() is 'a')
                  @list_el.on('touchend', => this.next(); this.cycle(); return false)
                  
                  return this

  next:         () ->
                  el = @list_el.children().first()
                  @list_el.addClass('transition')
                  el.removeClass('current').siblings().first().addClass('current')
                  
                  $(el.attr('data-related-p')).removeClass('current')
                  $(el.siblings().first().attr('data-related-p')).addClass('current')

                  window.setTimeout( => 
                    @list_el.removeClass('transition') # transition duration must be less than this timeout
                    el.detach()
                    el.appendTo(@list_el)
                  , 1000)

  cycle:        () ->
                  @_interval_id = window.setInterval( => 
                    this.next()
                  , @interval)


  pause:        () ->
                  window.clearInterval(@_interval_id)
