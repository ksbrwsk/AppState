import SwiftUI

struct app {
    var name: String = ""
    var url: String = ""
}

struct ContentView: View {
    @Environment(\.openURL) var openURL

    // Array of popular websites to check
    let popularSites = [
        app(name: "Homepage", url: "https://ksbrwsk.de"),
        app(name: "QR Code Generator", url: "https://ksbrwsk.de:9080"),
        app(name: "Vokabeltrainer", url: "https://ksbrwsk.de:8080"),
        app(name: "App Status", url: "https://ksbrwsk.de:9060"),
        app(name: "Free TV Player", url: "https://ksbrwsk.de:9070"),
    ]

    // State to track current URL input for each text field
    @State private var urlInputs: [app]

    // State to store the response log
    @State private var responseLog = ""

    // Initialize the URL inputs with the popular sites
    init() {
        _urlInputs = State(initialValue: popularSites)
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.top)
                Text("ksbrwsk.de")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
            }
            Form {
                ForEach(0..<urlInputs.count, id: \.self) { index in
                    HStack {
                        TextField("URL", text: $urlInputs[index].name)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                        Button {
                            openURL(URL(string: urlInputs[index].url)!)
                        } label: {
                            Image(systemName: "network")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            checkWebsite(app: urlInputs[index])
                        } label: {
                            Image(
                                systemName:
                                    "checkmark.arrow.trianglehead.counterclockwise"
                            )
                        }
                        .buttonStyle(.borderedProminent)

                    }
                }
            }

            HStack {

                Button("Clear Log") {
                    responseLog = ""
                }
                .buttonStyle(.borderedProminent)

            }

            // Terminal-style text view
            ScrollView {
                Text(responseLog.isEmpty ? "No responses yet" : responseLog)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(8)
            .padding()
        }
        //.padding()

    }

    // Function to check if website is accessible
    private func checkWebsite(app: app) {
        guard let urlObject = URL(string: app.url) else {
            // Clear and set log with error message
            responseLog = "Invalid URL: \(app.url)"
            return
        }

        // Clear log before making a new request
        //responseLog = "*** Testing\n \(app.url) -----\nSending request..."

        responseLog = "Testing \"\(app.name)\"\n\(app.url)\n"
        // Create a URLSessionConfiguration with a timeout
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0  // 10 seconds timeout

        // Create a URLSession with the configuration
        let session = URLSession(configuration: configuration)

        let task = session.dataTask(with: urlObject) { data, response, error in
            // Back to the main thread for UI updates
            DispatchQueue.main.async {
                if let error = error {
                    self.appendToLog("Error: ❌ SERVER DOWN")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.appendToLog("Invalid response")
                    return
                }

                let statusMessage = "Status code: \(httpResponse.statusCode)"
                let resultMessage: String

                switch httpResponse.statusCode {
                case 200...299:
                    resultMessage = "✅ SUCCESS: \(statusMessage)"
                case 400...499:
                    resultMessage = "⚠️ CLIENT ERROR: \(statusMessage)"
                case 500...599:
                    resultMessage = "❌ SERVER ERROR: \(statusMessage)"
                default:
                    resultMessage = "❓ UNKNOWN: \(statusMessage)"
                }

                self.appendToLog(resultMessage)

                // Add headers information
                //self.appendToLog("\nHeaders:")
                //if let fields = httpResponse.allHeaderFields as? [String: Any] {
                //    for (key, value) in fields {
                //        self.appendToLog("  \(key): \(value)")
                //    }
                //}
            }
        }

        task.resume()
    }

    // Helper function to append text to the log
    private func appendToLog(_ text: String) {
        if responseLog.isEmpty {
            responseLog = text
        } else {
            responseLog += "\n" + text
        }
    }
}

#Preview {
    ContentView()
}
