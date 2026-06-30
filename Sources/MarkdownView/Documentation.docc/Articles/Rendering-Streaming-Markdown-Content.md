# Rendering streaming markdown content

Build streaming AI interfaces by separating incoming markdown updates from SwiftUI view updates.

## Overview

AI responses often arrive in very small chunks. When you store each chunk in ordinary SwiftUI view state and depend on view-driven callbacks to parse it, SwiftUI can merge rapid updates before your parser sees every intermediate value. That makes the rendering work less predictable and adds extra view invalidations while content is still changing.

Use ``StreamingMarkdownSource`` and ``StreamingMarkdownReader`` to keep the streaming pipeline explicit. The source stores the latest markdown text and emits updates through its own async stream. The reader consumes those updates, coalesces rapid changes, and incrementally reparses the document so stable blocks can be reused between renders.

## Keep one source for one response

Create a ``StreamingMarkdownSource`` when a response starts. Keep that instance alive for the lifetime of the streamed response, and pass it to ``StreamingMarkdownReader``.

```swift
import MarkdownView
import SwiftUI

struct StreamingResponseView: View {
    @State private var markdownSource = StreamingMarkdownSource()

    var body: some View {
        StreamingMarkdownReader(markdownSource) { parseResult in
            MarkdownView(parseResult)
        }
    }
}
```

This structure keeps markdown parsing work tied to the source instead of the SwiftUI view refresh cycle.

## Append incoming content directly to the source

Update ``StreamingMarkdownSource/text`` whenever a new chunk arrives. Let the reader observe those changes and produce the next ``MarkdownParseResult``.

```swift
import MarkdownView
import SwiftUI

struct StreamingResponseView: View {
    @State private var markdownSource = StreamingMarkdownSource()
    let chunks: AsyncStream<String>

    var body: some View {
        StreamingMarkdownReader(markdownSource) { parseResult in
            MarkdownView(parseResult)
        }
        .task {
            for await chunk in chunks {
                markdownSource.text += chunk
            }

            markdownSource.finishStreaming()
        }
    }
}
```

## Tune the streaming render throttle when needed

Use ``SwiftUICore/View/markdownStreamingRenderThrottle(_:)`` to change how frequently ``StreamingMarkdownReader`` publishes visible updates while the source is still changing.

```swift
StreamingMarkdownReader(markdownSource) { parseResult in
    MarkdownView(parseResult)
}
.markdownStreamingRenderThrottle(.milliseconds(120))
```

The default throttle is `50` milliseconds. Increase it when streamed updates arrive very quickly and you want to reduce view invalidation work. Decrease it when you want the rendered output to track the stream more closely.

## Finish the stream when the response completes

Call ``StreamingMarkdownSource/finishStreaming()`` after the final chunk arrives. Finishing the source closes its internal update stream, then ``StreamingMarkdownReader`` performs one final full parse from the last emitted text so the rendered document reflects the completed markdown structure.

After a source finishes, it still stores later ``StreamingMarkdownSource/text`` assignments and stops emitting updates. Create a new source for the next streamed response.

## Keep the renderer driven by parse results

Pass the parse result from ``StreamingMarkdownReader`` straight into ``MarkdownView`` or ``MarkdownText``.

```swift
StreamingMarkdownReader(markdownSource) { parseResult in
    MarkdownView(parseResult)
}
```

This keeps rendering aligned with the parser output and avoids reparsing the same markdown again inside child views.
