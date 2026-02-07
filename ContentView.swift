// ContentView.swift (All-in-One)

import SwiftUI
import PhotosUI

// MARK: - Models

struct DashboardListing: Identifiable, Codable {
    let id: Int
    let title: String
    let price: String
    let category: String?
    let description: String?
    let image_path: String?
}

struct ListingsResponse: Codable {
    let success: Bool
    let listings: [DashboardListing]
}

// MARK: - Constants

enum API {
    static let base = "https://istockhomes.com/App/api"
    static let login = "\(base)/login.php"
    static let submitListing = "\(base)/submit-listing.php"
    static let allListings = "\(base)/AllListings.php"
}

// MARK: - ContentView

struct ContentView: View {
    @State private var listings: [DashboardListing] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedCategory: String = "All"
    @State private var showMenu = false
    @State private var isLoggedIn = false
    @State private var username = ""

    let categories = ["All", "Business", "Marine", "Aircraft", "Housing", "Art", "Domains", "Automotive"]

    var filteredListings: [DashboardListing] {
        selectedCategory == "All" ? listings : listings.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: "https://istockhomes.com/App/images/Paruse.png")) { image in
                    image.resizable().scaledToFit().frame(maxHeight: 80)
                } placeholder: {
                    ProgressView()
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \ .self) { cat in
                            Text(cat)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(cat == selectedCategory ? Color.black : Color.gray.opacity(0.2))
                                .foregroundColor(cat == selectedCategory ? .white : .black)
                                .cornerRadius(20)
                                .onTapGesture { selectedCategory = cat }
                        }
                    }.padding(.horizontal)
                }

                if isLoading {
                    ProgressView("Loading Listings...").padding()
                } else if let errorMessage {
                    Text("\(errorMessage)").foregroundColor(.red)
                } else if filteredListings.isEmpty {
                    Text("No listings match this category.").foregroundColor(.secondary)
                } else {
                    List(filteredListings) { listing in
                        VStack(alignment: .leading) {
                            Text(listing.title).font(.headline)
                            Text(formattedPrice(listing.price)).font(.caption).foregroundColor(.green)

                            if let imagePath = listing.image_path, let url = URL(string: imagePath.hasPrefix("http") ? imagePath : "https://istockhomes.com/App/\(imagePath)") {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill().frame(maxHeight: 200).cornerRadius(8)
                                        .onTapGesture(count: 2) {
                                            if let link = URL(string: "https://istockhomes.com/App/full-listing.php?id=\(listing.id)") {
                                                UIApplication.shared.open(link)
                                            }
                                        }
                                } placeholder: { ProgressView() }
                            }
                        }.padding(.vertical, 4)
                    }.listStyle(.plain)
                }

                Spacer()

                VStack {
                    AsyncImage(url: URL(string: "https://istockhomes.com/App/images/Istockhomes_logo-2020-Clear.jpg")) { image in
                        image.resizable().scaledToFit().frame(height: 30).opacity(0.8)
                    } placeholder: {
                        ProgressView()
                    }
                    Text("Branded & Verified").font(.footnote).foregroundColor(.secondary)
                }.padding(.bottom, 12)
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showMenu.toggle() } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            .sheet(isPresented: $showMenu) {
                AppMenuView(isLoggedIn: $isLoggedIn, username: $username)
            }
            .onAppear(perform: loadListings)
        }
    }

    func loadListings() {
        guard let url = URL(string: API.allListings) else { errorMessage = "Invalid URL"; return }
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                } else if let data = data {
                    do {
                        listings = try JSONDecoder().decode(ListingsResponse.self, from: data).listings
                    } catch {
                        errorMessage = "Decode error: \(error.localizedDescription)"
                    }
                }
            }
        }.resume()
    }

    func formattedPrice(_ price: String) -> String {
        let cleaned = price.replacingOccurrences(of: "$", with: "")
        if let value = Double(cleaned) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
        }
        return price
    }
}

// MARK: - AppMenuView

struct AppMenuView: View {
    @Binding var isLoggedIn: Bool
    @Binding var username: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("PARUSE MENU").font(.title).bold()

                if isLoggedIn {
                    Text("Welcome, \(username)").font(.headline)
                    NavigationLink("Add a Listing") { UploadImageView() }
                    Button("Log Out") {
                        isLoggedIn = false
                        username = ""
                    }.foregroundColor(.red)
                } else {
                    NavigationLink("Sign In") {
                        LoginView(isLoggedIn: $isLoggedIn, username: $username)
                    }
                }

                Spacer()
            }.padding()
        }
    }
}

// MARK: - LoginView

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var username: String
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign In").font(.largeTitle).bold()
            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)

            if let errorMessage { Text(errorMessage).foregroundColor(.red) }

            Button("Sign In") { login() }.buttonStyle(.borderedProminent)

            Spacer()
        }.padding()
    }

    func login() {
        guard let url = URL(string: API.login) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyString = "email=\(email)&password=\(password)"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               json["success"] as? Bool == true {
                DispatchQueue.main.async {
                    self.username = json["username"] as? String ?? self.email
                    self.isLoggedIn = true
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Login failed"
                }
            }
        }.resume()
    }
}

// MARK: - UploadImageView (Basic version)

struct UploadImageView: View {
    @State private var title = ""
    @State private var price = ""
    @State private var description = ""
    @State private var category = "Art"
    @State private var message: String?

    var body: some View {
        Form {
            Section(header: Text("Listing Details")) {
                TextField("Title", text: $title)
                TextField("Price", text: $price)
                TextField("Category", text: $category)
                TextEditor(text: $description).frame(height: 100)
            }

            Button("Submit Listing") {
                submitListing()
            }

            if let message {
                Text(message).foregroundColor(.blue)
            }
        }
    }

    func submitListing() {
        guard let url = URL(string: API.submitListing) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let bodyString = "title=\(title)&price=\(price)&category=\(category)&description=\(description)"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.message = "Uploaded successfully"
            }
        }.resume()
    }
}

