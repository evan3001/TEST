import SwiftUI

// MARK: - Allowed Apps Settings View
// Users configure which apps remain accessible during focus mode

struct AllowedAppsView: View {
    @EnvironmentObject var viewModel: FocusViewModel
    @State private var showAddCustomApp = false
    @State private var customBundleID = ""
    @State private var customAppName = ""

    var body: some View {
        NavigationStack {
            List {
                // Explanation Section
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)
                        Text("집중 모드 중에도 사용할 수 있는 앱을 선택하세요. 업무용 메신저 등을 허용할 수 있습니다.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                // Preset Categories
                Section("앱 목록") {
                    ForEach($viewModel.allowedApps) { $app in
                        allowedAppRow(app: $app)
                    }
                }

                // Screen Time App Picker (iOS only)
                #if canImport(FamilyControls)
                Section("차단할 앱 선택") {
                    screenTimePickerSection
                }
                #endif

                // Custom App
                Section {
                    Button {
                        showAddCustomApp = true
                    } label: {
                        Label("사용자 지정 앱 추가", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("앱 설정")
            .sheet(isPresented: $showAddCustomApp) {
                addCustomAppSheet
            }
        }
    }

    // MARK: - App Row

    private func allowedAppRow(app: Binding<AllowedApp>) -> some View {
        HStack {
            Image(systemName: app.wrappedValue.iconSystemName)
                .font(.title3)
                .foregroundStyle(app.wrappedValue.isEnabled ? .blue : .gray)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.wrappedValue.displayName)
                    .font(.body)
                Text(app.wrappedValue.bundleIdentifier)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: app.isEnabled)
                .labelsHidden()
                .onChange(of: app.wrappedValue.isEnabled) {
                    viewModel.saveAllowedAppsExternally()
                }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Screen Time Picker (iOS/iPadOS)

    #if canImport(FamilyControls)
    import FamilyControls

    private var screenTimePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Screen Time API를 통해 차단할 앱과 카테고리를 선택합니다.")
                .font(.caption)
                .foregroundStyle(.secondary)

            FamilyActivityPicker(selection: $viewModel.screenTimeSelection)
                .onChange(of: viewModel.screenTimeSelection) {
                    ScreenTimeManager.shared.updateBlockedApps(viewModel.screenTimeSelection)
                }
        }
    }
    #endif

    // MARK: - Custom App Sheet

    private var addCustomAppSheet: some View {
        NavigationStack {
            Form {
                Section("앱 정보") {
                    TextField("앱 이름", text: $customAppName)
                    TextField("Bundle ID (예: com.example.app)", text: $customBundleID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("앱 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { showAddCustomApp = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        viewModel.addCustomApp(bundleID: customBundleID, name: customAppName)
                        showAddCustomApp = false
                        customBundleID = ""
                        customAppName = ""
                    }
                    .disabled(customBundleID.isEmpty || customAppName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - ViewModel Extension for External Save

extension FocusViewModel {
    func saveAllowedAppsExternally() {
        if let data = try? JSONEncoder().encode(allowedApps) {
            UserDefaults.standard.set(data, forKey: "allowedApps")
        }
    }
}
