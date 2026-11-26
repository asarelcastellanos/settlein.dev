import SwiftUI

struct AnimatedIcon: View {
    let size: CGFloat
    var animated = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var played = false

    private struct Tile {
        let centre: CGPoint
        let angle: Double
        let start: CGSize
    }

    private let tiles = [
        Tile(centre: CGPoint(x: 328, y: 430), angle: -28, start: CGSize(width: 184, height: 174)),
        Tile(centre: CGPoint(x: 512, y: 330), angle: 0, start: CGSize(width: 0, height: 274)),
        Tile(centre: CGPoint(x: 696, y: 430), angle: 28, start: CGSize(width: -184, height: 174)),
    ]

    private var shown: Bool { played || reduceMotion || !animated }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("IconBack").resizable().frame(width: 1024, height: 1024)
            ForEach(tiles.indices, id: \.self) { index in tile(tiles[index], index: index) }
            Image("IconFront").resizable().frame(width: 1024, height: 1024)
        }
        .frame(width: 1024, height: 1024)
        .scaleEffect(size / 1024, anchor: .topLeading)
        .frame(width: size, height: size, alignment: .topLeading)
        .onAppear { played = true }
        .accessibilityHidden(true)
    }

    private func tile(_ tile: Tile, index: Int) -> some View {
        let delay = 0.12 * Double(index)
        return ZStack {
            RoundedRectangle(cornerRadius: 30).fill(Color.black.opacity(0.16)).offset(y: 8)
            RoundedRectangle(cornerRadius: 30).fill(Color.white)
        }
        .frame(width: 128, height: 128)
        .rotationEffect(.degrees(shown ? tile.angle : 0))
        .scaleEffect(shown ? 1 : 0.25)
        .offset(shown ? .zero : tile.start)
        .animation(reduceMotion || !animated ? nil : .spring(response: 0.55, dampingFraction: 0.62).delay(delay), value: shown)
        .opacity(shown ? 1 : 0)
        .animation(reduceMotion || !animated ? nil : .easeOut(duration: 0.135).delay(delay), value: shown)
        .position(x: tile.centre.x, y: tile.centre.y - 55)
    }
}
