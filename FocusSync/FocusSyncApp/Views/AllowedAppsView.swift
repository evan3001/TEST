import SwiftUI

struct AllowedAppsView: View {
    @EnvironmentObject var vm: FocusViewModel
    @State private var showAddSheet = false
    @State private var newName = ""
    @State private var newBundleID = ""

    var body: some View {
        NavigationStack {
            List {
                // 설명
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

                // 앱 목록
                Section("허용 앱 목록") {
                    ForEach(vm.allowedApps) { app in
                        HStack(spacing: 12) {
                            Image(systemName: app.iconSystemName)
                                .font(.title3)
                                .foregroundStyle(app.isEnabled ? .blue : .gray)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.displayName)
                                    .font(.body)
                                Text(app.bundleIdentifier)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { app.isEnabled },
                                set: { _ in vm.toggleApp(app) }
                            ))
                            .labelsHidden()
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete { vm.removeApp(at: $0) }
                }

                // 추가 버튼
                Section {
                    Button {
                        showAddSheet = true
                    } label: {
                        Label("사용자 지정 앱 추가", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("앱 설정")
            .sheet(isPresented: $showAddSheet) {
                NavigationStack {
                    Form {
                        Section("앱 정보") {
                            TextField("앱 이름", text: $newName)
                            TextField("Bundle ID (예: com.example.app)", text: $newBundleID)
                            #if os(iOS)
                                .textInputAutocapitalization(.never)
                            #endif
                                .autocorrectionDisabled()
                        }
                    }
                    .navigationTitle("앱 추가")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("취소") { showAddSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("추가") {
                                vm.addCustomApp(bundleID: newBundleID, name: newName)
                                showAddSheet = false
                                newName = ""
                                newBundleID = ""
                            }
                            .disabled(newName.isEmpty || newBundleID.isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
}
