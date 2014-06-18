
doctype

html
  head
    title "In Crowd"
    meta (:charset utf-8)
    link (:rel stylesheet) (:href css/style.css)
    link (:rel icon) (:type image/png) (:href png/in-crowd.png)
    @if (@ inDev) $ @block
      link (:rel stylesheet) (:href css/dev.css)
      script (:src bower_components/react/react.js)
    @if (@ inBuild) $ @block
      link (:rel stylesheet) (:href css/build.css)
      script (:src //cdn.staticfile.org/react/0.10.0/react.min.js)
    script (:defer) (:src build/main.js)

  body