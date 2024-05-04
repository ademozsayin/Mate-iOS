import Foundation
import UIKit
import FiableRedux


/// Default implementation of the ReviewsDataSource, dequeues and
/// populates cells to render the Product Review list
///
final class ReviewsDataSource: NSObject, ReviewsDataSourceProtocol {

    // MARK: - Private properties

    /// Adds an extra layer of logic customization depending on the case (e.g only reviews of a specific product, global site reviews...)
    private let customizer: ReviewsDataSourceCustomizing

    /// Product Reviews
    ///
    private lazy var reviewsResultsController: ResultsController<StorageProductReview> = {
        let storageManager = ServiceLocator.storageManager
        let descriptor = NSSortDescriptor(keyPath: \StorageProductReview.dateCreated, ascending: false)

        return ResultsController<StorageProductReview>(storageManager: storageManager,
                                                       sectionNameKeyPath: "normalizedAgeAsString",
                                                       matching: customizer.reviewsFilterPredicate(with: sitePredicate()),
                                                       sortedBy: [descriptor])
    }()

    /// Products
    ///
    private lazy var productsResultsController: ResultsController<StorageEvent> = {
        let storageManager = ServiceLocator.storageManager
        let descriptor = NSSortDescriptor(keyPath: \StorageEvent.id, ascending: true)

        return ResultsController<StorageEvent>(storageManager: storageManager,
                                                       matching: nil,//sitePredicate(),
                                                       sortedBy: [descriptor])
    }()

    /// Notifications
    ///
    private lazy var notificationsResultsController: ResultsController<StorageNote> = {
        let storageManager = ServiceLocator.storageManager
        let descriptor = NSSortDescriptor(keyPath: \StorageNote.timestamp, ascending: false)

        return ResultsController<StorageNote>(storageManager: storageManager,
                                              sectionNameKeyPath: "normalizedAgeAsString",
                                              matching: notificationsPredicate,
                                              sortedBy: [descriptor])
    }()

    private lazy var notificationsPredicate: NSPredicate = {
        let notDeletedPredicate = NSPredicate(format: "deleteInProgress == NO")
        let typeReviewPredicate =  NSPredicate(format: "subtype == %@", Note.Subkind.storeReview.rawValue)

        return NSCompoundPredicate(andPredicateWithSubpredicates: [typeReviewPredicate,
                                                                   notDeletedPredicate])
    }()

    /// Keep track of the (Autosizing Cell's) Height. This helps us prevent UI flickers, due to sizing recalculations.
    ///
    private var estimatedRowHeights = [IndexPath: CGFloat]()

    // MARK: - Private properties

    /// Boolean indicating if there are reviews
    ///
    var isEmpty: Bool {
        return reviewsResultsController.isEmpty
    }

    /// Notifications associated with the reviews.
    ///
    var notifications: [Note] {
        return notificationsResultsController.fetchedObjects
    }

    var reviewCount: Int {
        return reviewsResultsController.numberOfObjects
    }

    init( customizer: ReviewsDataSourceCustomizing) {
        self.customizer = customizer
        super.init()
        observeResults()
    }

    /// Initialise obervers
    ///
    private func observeResults() {
        observeProducts()
        observeNotifications()
    }

    private func observeProducts() {
        try? productsResultsController.performFetch()
    }

    private func observeNotifications() {
        try? notificationsResultsController.performFetch()
    }

    /// Predicate to filter only Product Reviews that are either approved or on hold
    ///
    private func filterPredicate() -> NSPredicate {
        let statusPredicate = NSPredicate(format: "statusKey ==[c] %@ OR statusKey ==[c] %@",
                                          ProductReviewStatus.approved.rawValue,
                                          ProductReviewStatus.hold.rawValue)

//        return  NSCompoundPredicate(andPredicateWithSubpredicates: [sitePredicate, statusPredicate])
        return  NSCompoundPredicate(andPredicateWithSubpredicates: [statusPredicate])

    }

    /// Predicate to entities that belong to the current store
    ///
    private func sitePredicate() -> NSPredicate {
        return NSPredicate()
    }

    /// Initializes observers for incoming reviews
    ///
    func observeReviews() throws {
        try reviewsResultsController.performFetch()
    }

    func startForwardingEvents(to tableView: UITableView) {
        reviewsResultsController.startForwardingEvents(to: tableView)
    }

    func refreshDataObservers() {
        let sitePredicate = sitePredicate()
        reviewsResultsController.predicate = customizer.reviewsFilterPredicate(with: sitePredicate)
        productsResultsController.predicate = sitePredicate
    }
}


// MARK: - UITableViewDataSource Conformance
//
extension ReviewsDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return reviewsResultsController.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsResultsController.sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ProductReviewTableViewCell.self, for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let rawAge = reviewsResultsController.sections[section].name
        return ReviewAge(rawValue: rawAge)?.description
    }
}


// MARK: - Cell Setup
//
private extension ReviewsDataSource {

    /// Initializes the Notifications Cell at the specified indexPath
    ///
    func configure(_ cell: ProductReviewTableViewCell, at indexPath: IndexPath) {
        let viewModel = reviewViewModel(at: indexPath)

        cell.configure(with: viewModel)
    }

    private func reviewViewModel(at indexPath: IndexPath) -> ReviewViewModel {
        let review = reviewsResultsController.object(at: indexPath)
        let reviewProduct = product(id: review.productID)
        let note = notification(id: review.reviewID)

        return ReviewViewModel(showProductTitle: customizer.shouldShowProductTitleOnCells, review: review, product: reviewProduct, notification: note)
    }

    private func product(id productID: Int64) -> MateEvent? {
        let products = productsResultsController.fetchedObjects

        return products.filter { $0.id == productID }.first
    }

    private func notification(id reviewID: Int64) -> Note? {
//        let notifications = notificationsResultsController.fetchedObjects
//
//        return notifications.filter { $0.meta.identifier(forKey: .comment) == Int(reviewID) }.first
        return nil
    }
}


// MARK: - Conformance to ReviewsInteractionDelegate & UITableViewDelegate
//
extension ReviewsDataSource: ReviewsInteractionDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return estimatedRowHeights[indexPath] ?? Settings.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath, with syncingCoordinator: SyncingCoordinator) {

        let orderIndex = reviewsResultsController.objectIndex(from: indexPath)
        syncingCoordinator.ensureNextPageIsSynchronized(lastVisibleIndex: orderIndex)

        // Preserve the Cell Height
        // Why: Because Autosizing Cells, upon reload, will need to be laid yout yet again. This might cause
        // UI glitches / unwanted animations. By preserving it, *then* the estimated will be extremely close to
        // the actual value. AKA no flicker!
        //
        estimatedRowHeights[indexPath] = cell.frame.height
    }

    func didSelectItem(at indexPath: IndexPath, in viewController: UIViewController) {
        let review = reviewsResultsController.object(at: indexPath)
        let reviewedProduct = product(id: review.productID)
        let note = notification(id: review.reviewID)

        ServiceLocator.analytics.track(.reviewOpen)

        let detailsViewController = ReviewDetailsViewController(productReview: review,
                                                                product: reviewedProduct,
                                                                notification: note)
        viewController.navigationController?.pushViewController(detailsViewController, animated: true)
    }
}


extension ReviewsDataSource {
    enum Settings {
        static let estimatedRowHeight = CGFloat(88)
    }
}


enum ReviewAge: String {
    case last24Hours = "0"
    case last7Days   = "1"
    case theRest     = "2"

    var description: String {
        switch self {
        case .last24Hours:  return NSLocalizedString("Last 24 hours", comment: "Last 24 hours section header")
        case .last7Days:    return NSLocalizedString("Last 7 days", comment: "Last 7 days section header")
        case .theRest:      return NSLocalizedString("Older than 7 days", comment: "+7 Days Section Header")
        }
    }
}


// MARK: - Convenience Methods Initializers
//
extension ReviewAge {

    /// Returns the Age entity that best describes a given timespan.
    ///
    static func from(startDate: Date, toDate: Date) -> ReviewAge {
        let timeDifference = toDate.timeIntervalSince(startDate)
        let oneDayInSeconds: TimeInterval = 86_400

        if timeDifference <= oneDayInSeconds { // 24hrs
            return .last24Hours
        } else if timeDifference <= oneDayInSeconds * 7 { // 7 days
            return .last7Days
        } else {
            return .theRest
        }
    }
}
