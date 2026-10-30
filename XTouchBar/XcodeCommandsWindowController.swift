import AppKit
import XcodeCommandBridgeClient

/// Searchable browser for the full Xcode command registry snapshot.
final class XcodeCommandsWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate {
  private struct Entry {
    let id: String
    let selector: String
    let title: String
    let path: String
    let source: String
  }

  private var entries: [Entry] = []
  private var filteredEntries: [Entry] = []
  private let table = NSTableView()
  private let search = NSSearchField()
  private let details = NSTextField(wrappingLabelWithString: "Choose a command to see its details.")
  private let status = NSTextField(labelWithString: "")
  private let runButton = NSButton(title: "Run in Xcode", target: nil, action: nil)
  private let queue = DispatchQueue(label: "com.xtouchbar.command-browser", qos: .userInitiated)
  private let bridge = XcodeCommandBridgeClient()

  init() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 900, height: 620),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false
    )
    window.title = "Xcode Commands"
    window.center()
    super.init(window: window)
    buildInterface()
    loadCatalog()
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func numberOfRows(in tableView: NSTableView) -> Int { filteredEntries.count }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let cellID = NSUserInterfaceItemIdentifier("CommandCell")
    let cell = (tableView.makeView(withIdentifier: cellID, owner: self) as? NSTableCellView) ?? {
      let view = NSTableCellView()
      let label = NSTextField(labelWithString: "")
      label.lineBreakMode = .byTruncatingMiddle
      label.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(label)
      view.textField = label
      NSLayoutConstraint.activate([
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      ])
      view.identifier = cellID
      return view
    }()
    guard row < filteredEntries.count, let key = tableColumn?.identifier.rawValue else { return cell }
    let entry = filteredEntries[row]
    switch key {
    case "title": cell.textField?.stringValue = entry.title
    case "path": cell.textField?.stringValue = entry.path
    case "id": cell.textField?.stringValue = entry.id
    default: break
    }
    return cell
  }

  func tableViewSelectionDidChange(_ notification: Notification) {
    guard table.selectedRow >= 0, table.selectedRow < filteredEntries.count else {
      details.stringValue = "Choose a command to see its details."
      runButton.isEnabled = false
      return
    }
    let entry = filteredEntries[table.selectedRow]
    details.stringValue = "\(entry.path)\n\nIdentifier: \(entry.id)\nSelector: \(entry.selector)"
      + "\nSource: \(entry.source)\n\nDispatch success means Xcode accepted the action;"
      + " it does not confirm that the action finished."
    runButton.isEnabled = true
  }

  func controlTextDidChange(_ notification: Notification) { applyFilter() }

  @objc
  private func runSelectedCommand() {
    guard table.selectedRow >= 0, table.selectedRow < filteredEntries.count else { return }
    let entry = filteredEntries[table.selectedRow]
    runButton.isEnabled = false
    status.stringValue = "Sending \(entry.title)…"
    queue.async {
      do {
        _ = try self.bridge.execute(identifier: entry.id)
        DispatchQueue.main.async {
          self.status.stringValue = "Dispatched: \(entry.title)"
          self.runButton.isEnabled = true
        }
      } catch {
        DispatchQueue.main.async {
          self.status.stringValue = error.localizedDescription
          self.runButton.isEnabled = true
        }
      }
    }
  }

  // swiftlint:disable:next function_body_length
  private func buildInterface() {
    guard let window, let content = window.contentView else { return }
    search.placeholderString = "Search by command, menu path, or identifier"
    search.delegate = self
    search.translatesAutoresizingMaskIntoConstraints = false

    let columns = [("title", "Command", 220.0), ("path", "Menu Path", 300.0), ("id", "Identifier", 330.0)]
    for (key, title, width) in columns {
      let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(key))
      column.title = title
      column.width = width
      table.addTableColumn(column)
    }
    table.headerView = NSTableHeaderView()
    table.usesAlternatingRowBackgroundColors = true
    table.delegate = self
    table.dataSource = self
    table.doubleAction = #selector(runSelectedCommand)
    table.target = self
    let scroll = NSScrollView()
    scroll.documentView = table
    scroll.hasVerticalScroller = true
    scroll.translatesAutoresizingMaskIntoConstraints = false

    details.font = .systemFont(ofSize: 12)
    details.lineBreakMode = .byWordWrapping
    details.maximumNumberOfLines = 0
    details.translatesAutoresizingMaskIntoConstraints = false
    status.lineBreakMode = .byTruncatingTail
    status.translatesAutoresizingMaskIntoConstraints = false
    runButton.target = self
    runButton.action = #selector(runSelectedCommand)
    runButton.isEnabled = false
    runButton.translatesAutoresizingMaskIntoConstraints = false
    let footer = NSStackView(views: [details, runButton])
    footer.orientation = .horizontal
    footer.alignment = .top
    footer.spacing = 16
    footer.translatesAutoresizingMaskIntoConstraints = false
    content.addSubview(search)
    content.addSubview(scroll)
    content.addSubview(footer)
    content.addSubview(status)
    NSLayoutConstraint.activate([
      search.topAnchor.constraint(equalTo: content.topAnchor, constant: 16),
      search.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
      search.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
      scroll.topAnchor.constraint(equalTo: search.bottomAnchor, constant: 12),
      scroll.leadingAnchor.constraint(equalTo: search.leadingAnchor),
      scroll.trailingAnchor.constraint(equalTo: search.trailingAnchor),
      scroll.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -12),
      footer.leadingAnchor.constraint(equalTo: search.leadingAnchor),
      footer.trailingAnchor.constraint(lessThanOrEqualTo: search.trailingAnchor),
      footer.bottomAnchor.constraint(equalTo: status.topAnchor, constant: -8),
      details.widthAnchor.constraint(greaterThanOrEqualToConstant: 540),
      runButton.widthAnchor.constraint(equalToConstant: 130),
      status.leadingAnchor.constraint(equalTo: search.leadingAnchor),
      status.trailingAnchor.constraint(equalTo: search.trailingAnchor),
      status.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -12)
    ])
  }

  private func loadCatalog() {
    guard let url = Bundle.main.url(forResource: "CommandCatalogSnapshot", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let rawEntries = root["entries"] as? [[String: Any]] else {
      status.stringValue = "Could not load the bundled command catalog."
      return
    }
    entries = rawEntries.compactMap { item in
      guard let id = item["id"] as? String, let selector = item["selector"] as? String,
            let title = item["title"] as? String, let path = item["path"] as? String else { return nil }
      return Entry(id: id, selector: selector, title: title, path: path, source: item["source"] as? String ?? "unknown")
    }.sorted { $0.path.localizedCaseInsensitiveCompare($1.path) == .orderedAscending }
    filteredEntries = entries
    table.reloadData()
    status.stringValue = "\(entries.count) commands in the catalog. Xcode must be running with the command bridge loaded to run one."
  }

  private func applyFilter() {
    let query = search.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else { filteredEntries = entries; table.reloadData(); return }
    filteredEntries = entries.filter {
      $0.title.localizedCaseInsensitiveContains(query) || $0.path.localizedCaseInsensitiveContains(query) ||
        $0.id.localizedCaseInsensitiveContains(query) || $0.selector.localizedCaseInsensitiveContains(query)
    }
    table.reloadData()
  }
}
