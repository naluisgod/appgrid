import SwiftUI

struct AppItem: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let icon: NSImage
}

struct ContentView: View {

    @State private var apps: [AppItem] = []

    var body: some View {
        ZStack {
            Rectangle()
                .background(Color.black.opacity(0.35))
                .ignoresSafeArea()

            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 240), spacing: 60)],
                    spacing: 60
                ) {
                    ForEach(apps) { app in
                        VStack(spacing: 12) {
                            Image(nsImage: app.icon)
                                .resizable()
                                .frame(width: 192, height: 192)
                                .cornerRadius(24)

                            Text(app.name)
                                .font(.caption)
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .onTapGesture {
                            NSWorkspace.shared.open(app.url)
                        }
                    }
                }
                .padding(80)
            }
        }
        .onAppear {
            loadApplications()
            DispatchQueue.main.async {
                NSApp.keyWindow?.toggleFullScreen(nil)
            }
        }
        .onExitCommand {
            NSApp.terminate(nil)
        }
    }

    // MARK: - Load Applications

    private func loadApplications() {
        let appDirs = [
            "/Applications",
            "/System/Applications",
            "\(NSHomeDirectory())/Applications"
        ]

        var foundApps: [AppItem] = []

        for dir in appDirs {
            let url = URL(fileURLWithPath: dir)
            let contents = (try? FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )) ?? []

            for appURL in contents where appURL.pathExtension == "app" {
                let name = appURL.deletingPathExtension().lastPathComponent
                let icon = NSWorkspace.shared.icon(forFile: appURL.path)
                icon.size = NSSize(width: 512, height: 512)

                foundApps.append(
                    AppItem(url: appURL, name: name, icon: icon)
                )
            }
        }

        apps = foundApps.sorted {
            $0.name.lowercased() < $1.name.lowercased()
        }
    }
}

