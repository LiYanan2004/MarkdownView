import MarkdownView
import SwiftUI

#Preview(traits: .markdownViewExample) {
    let markdownText = """
    - Solar System Exploration
      - Planetary Missions
        - Mars Rover Program
        - Venus Atmospheric Studies
        - Jupiter Moon Probes
      - Asteroid Sampling
        - Near-Earth Objects
          - OSIRIS-REx Mission
          - Hayabusa2 Project
        - Main Belt Asteroids
          - Dawn Mission to Ceres
          - Psyche Metal World Study
    """

    MarkdownView(markdownText)
}
