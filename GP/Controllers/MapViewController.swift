//
//  MapViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: - UI Elements
    private let mapView = MKMapView()
    private let searchField = UITextField()
    private let resultsTableView = UITableView()
    private var buttonBottomToViewConstraint: NSLayoutConstraint!
    private var buttonBottomToRouteInfoConstraint: NSLayoutConstraint!
    private var destinationAnnotation: MKPointAnnotation?
    private let clearButton = UIButton(type: .system)
    
    private let routeInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()
    
    private let startMonitoringButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Monitoring", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Location & Search
    private let locationManager = CLLocationManager()
    private let searchCompleter = MKLocalSearchCompleter()
    private var destinationCoordinate: CLLocationCoordinate2D?
    private var searchResults: [MKLocalSearchCompletion] = []
    
    // MARK: - Performance Optimizations
    private var searchTimer: Timer?
    private let searchDebounceInterval: TimeInterval = 0.3
    private var currentSearchTask: URLSessionDataTask?
    private let maxSearchResults = 10 // Lazy loading limit
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupSearchUI()
        configureLocation()
        
        mapView.delegate = self
        searchCompleter.delegate = self
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        startMonitoringButton.addTarget(self, action: #selector(startMonitoringTapped), for: .touchUpInside)
        
        // Configure map for better performance and caching
        configureMapPerformance()
        
        startMonitoringButton.translatesAutoresizingMaskIntoConstraints = false
        
        buttonBottomToViewConstraint = startMonitoringButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        buttonBottomToRouteInfoConstraint = startMonitoringButton.bottomAnchor.constraint(equalTo: routeInfoLabel.topAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            startMonitoringButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startMonitoringButton.widthAnchor.constraint(equalToConstant: 160),
            startMonitoringButton.heightAnchor.constraint(equalToConstant: 44),
            
            buttonBottomToViewConstraint
        ])
        
    }
    
    // MARK: - Memory Management
    deinit {
        // Cleanup to prevent memory leaks
        searchTimer?.invalidate()
        currentSearchTask?.cancel()
    }
}

extension MapViewController {
    func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupSearchUI() {
        // Configure search field
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.borderStyle = .roundedRect
        searchField.placeholder = "Enter Destination..."
        searchField.textColor = .label
        searchField.backgroundColor = .systemBackground
        searchField.delegate = self
        
        let searchIconButton = UIButton(type: .system)
        searchIconButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchIconButton.tintColor = .gray
        searchIconButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        searchIconButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchIconButton.translatesAutoresizingMaskIntoConstraints = false
        
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .gray
        clearButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        clearButton.addTarget(self, action: #selector(clearSearchTapped), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.isHidden = true
        
        
        // Configure results table
        resultsTableView.translatesAutoresizingMaskIntoConstraints = false
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.isHidden = true
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Add views
        view.addSubview(searchField)
        view.addSubview(searchIconButton)
        view.addSubview(clearButton)
        view.addSubview(resultsTableView)
        view.addSubview(routeInfoLabel)
        view.addSubview(startMonitoringButton)
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchField.heightAnchor.constraint(equalToConstant: 40),
            
            
            searchIconButton.topAnchor.constraint(equalTo: searchField.topAnchor),
            searchIconButton.bottomAnchor.constraint(equalTo: searchField.bottomAnchor),
            searchIconButton.trailingAnchor.constraint(equalTo: searchField.trailingAnchor, constant: -10),
            
            clearButton.topAnchor.constraint(equalTo: searchField.topAnchor),
            clearButton.bottomAnchor.constraint(equalTo: searchField.bottomAnchor),
            clearButton.trailingAnchor.constraint(equalTo: searchIconButton.leadingAnchor, constant: -5),
            
            resultsTableView.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            resultsTableView.leadingAnchor.constraint(equalTo: searchField.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: searchField.trailingAnchor),
            resultsTableView.heightAnchor.constraint(equalToConstant: 200),
            
            routeInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            routeInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            routeInfoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            routeInfoLabel.heightAnchor.constraint(equalToConstant: 50),
            
            
            startMonitoringButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startMonitoringButton.bottomAnchor.constraint(equalTo: routeInfoLabel.topAnchor, constant: -10),
            startMonitoringButton.widthAnchor.constraint(equalToConstant: 200),
            startMonitoringButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func configureLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
        mapView.showsUserLocation = true
        
        // Start location updates
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        
        // Center map on user location when first loaded
        if !mapView.isUserLocationVisible {
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: 2000,
                longitudinalMeters: 2000
            )
            mapView.setRegion(region, animated: true)
            
            // Stop frequent updates after initial location is set
            locationManager.stopUpdatingLocation()
        }
        
        // If we have a destination, update the route
        if let destination = destinationCoordinate {
            showRoute(to: destination)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showAlert(title: "Location Access Denied",
                      message: "Please enable location access in Settings to use this feature.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        showAlert(title: "Location Error",
                  message: "Unable to get your location. Please check your location settings.")
    }
}

extension MapViewController {
    @objc func searchButtonTapped() {
        if let query = searchField.text, !query.isEmpty {
            performSearch(query: query)
        }
    }
    
    @objc func searchTextChanged() {
        // Performance Optimization: Debounce search requests
        searchTimer?.invalidate()
        
        let searchText = searchField.text ?? ""
        clearButton.isHidden = searchText.isEmpty
        
        // Cancel previous search if still running
        currentSearchTask?.cancel()
        
        if searchText.isEmpty {
            searchResults = []
            resultsTableView.reloadData()
            resultsTableView.isHidden = true
            return
        }
        
        // Debounce the search to reduce API calls
        searchTimer = Timer.scheduledTimer(withTimeInterval: searchDebounceInterval, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.searchCompleter.queryFragment = searchText
            }
        }
        
        buttonBottomToViewConstraint.isActive = false
        buttonBottomToRouteInfoConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func clearSearchTapped() {
        // Clear the search field
        searchField.text = ""
        searchField.resignFirstResponder()
        
        // Hide search results
        resultsTableView.isHidden = true
        searchResults = []
        resultsTableView.reloadData()
        
        // Hide clear button
        clearButton.isHidden = true
        
        // Clear route and destination
        destinationCoordinate = nil
        mapView.removeOverlays(mapView.overlays)
        
        // Remove destination annotation
        if let annotation = destinationAnnotation {
            mapView.removeAnnotation(annotation)
            destinationAnnotation = nil
        }
        
        // Hide route info and monitoring button
        routeInfoLabel.isHidden = true
        startMonitoringButton.isHidden = true
        
        // Reset button constraints
        buttonBottomToRouteInfoConstraint.isActive = false
        buttonBottomToViewConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        // Clear search completer
        searchCompleter.queryFragment = ""
    }
    
    @objc private func startMonitoringTapped() {
        // Get the main tab bar controller
        guard let tabBarController = self.tabBarController as? MainTabBarViewController else {
            print("Error: Could not access main tab bar controller")
            return
        }
        tabBarController.selectedIndex = 1
    }
    
    func performSearch(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        MKLocalSearch(request: request).start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Search Error", message: error.localizedDescription)
                return
            }
            
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                self.showAlert(title: "Not Found", message: "No results for \"\(query)\"")
                return
            }
            
            self.destinationCoordinate = coordinate
            self.showRoute(to: coordinate)
        }
    }
    
    func showRoute(to destinationCoordinate: CLLocationCoordinate2D) {
        guard let userLocation = mapView.userLocation.location else {
            showAlert(title: "Location Error", message: "User location unavailable.")
            return
        }
        
        // Remove existing destination pin if any
        if let existingAnnotation = destinationAnnotation {
            mapView.removeAnnotation(existingAnnotation)
        }
        
        // Add new destination pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = destinationCoordinate
        annotation.title = "Destination"
        mapView.addAnnotation(annotation)
        destinationAnnotation = annotation
        
        // Performance Optimization: Cancel any ongoing route calculation
        currentSearchTask?.cancel()
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first else {
                self?.showAlert(title: "Route Error", message: "Unable to calculate route.")
                return
            }
            
            // Performance Optimization: Clear previous overlays before adding new ones
            DispatchQueue.main.async {
                self.mapView.removeOverlays(self.mapView.overlays)
                
                // For long routes, simplify the polyline to improve performance
                let simplifiedPolyline = self.simplifyPolylineIfNeeded(route.polyline)
                self.mapView.addOverlay(simplifiedPolyline)
                
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                self.displayDistanceAndETA(for: route)
            }
        }
    }
    
    func displayDistanceAndETA(for route: MKRoute) {
        let distance = String(format: "%.2f km", route.distance / 1000)
        let hours = Int(route.expectedTravelTime) / 3600
        let minutes = (Int(route.expectedTravelTime) % 3600) / 60
        let eta = "\(hours > 0 ? "\(hours)h " : "")\(minutes)m"
        
        DispatchQueue.main.async {
            self.routeInfoLabel.text = "Distance: \(distance)\nETA: \(eta)"
            self.routeInfoLabel.isHidden = false
            self.startMonitoringButton.isHidden = false
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize user location annotation
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "DestinationPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        if let markerView = annotationView as? MKMarkerAnnotationView {
            markerView.markerTintColor = .red
            markerView.glyphImage = UIImage(systemName: "mappin.circle.fill")
        }
        
        return annotationView
    }
}

extension MapViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Performance Optimization: Lazy loading - limit results for better performance
        searchResults = Array(completer.results.prefix(maxSearchResults))
        
        DispatchQueue.main.async {
            self.resultsTableView.reloadData()
            self.resultsTableView.isHidden = self.searchResults.isEmpty
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Completer error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.searchResults = []
            self.resultsTableView.reloadData()
            self.resultsTableView.isHidden = true
        }
    }
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title + ", " + result.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let completion = searchResults[indexPath.row]
        MKLocalSearch(request: MKLocalSearch.Request(completion: completion)).start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Search Error", message: error.localizedDescription)
                return
            }
            
            guard let placemark = response?.mapItems.first?.placemark else {
                self.showAlert(title: "Location Error", message: "Location not found.")
                return
            }
            
            let coordinate = placemark.coordinate
            
            
            self.destinationCoordinate = coordinate
            self.showRoute(to: coordinate)
            self.searchField.text = placemark.name ?? completion.title
            self.resultsTableView.isHidden = true
            self.searchResults = []
            self.resultsTableView.reloadData()
            self.searchField.resignFirstResponder()
        }
    }
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, !text.isEmpty {
            performSearch(query: text)
        }
        return true
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Performance Optimization Methods
    
    private func configureMapPerformance() {
        // Configure map for better performance and tile caching
        mapView.preferredConfiguration = MKStandardMapConfiguration()
        
        // Set reasonable zoom limits to prevent excessive tile loading
        if #available(iOS 13.0, *) {
            mapView.cameraZoomRange = MKMapView.CameraZoomRange(
                minCenterCoordinateDistance: 100,
                maxCenterCoordinateDistance: 100000
            )
        }
        
        // Configure URL cache for better search result caching
        let cache = URLCache(memoryCapacity: 20 * 1024 * 1024, // 20MB memory
                             diskCapacity: 100 * 1024 * 1024,    // 100MB disk
                             diskPath: "MapSearchCache")
        URLCache.shared = cache
    }
    
    private func simplifyPolylineIfNeeded(_ polyline: MKPolyline) -> MKPolyline {
        // Performance Optimization: For long routes (>500 points), simplify the polyline
        let pointCount = polyline.pointCount
        
        if pointCount > 500 {
            // Create a simplified version by taking every nth point
            let simplificationFactor = max(2, pointCount / 250) // Target ~250 points max
            
            var simplifiedPoints: [CLLocationCoordinate2D] = []
            let points = polyline.points()
            
            for i in stride(from: 0, to: pointCount, by: simplificationFactor) {
                simplifiedPoints.append(points[i].coordinate)
            }
            
            // Always include the last point
            if pointCount > 0 && (pointCount - 1) % simplificationFactor != 0 {
                simplifiedPoints.append(points[pointCount - 1].coordinate)
            }
            
            return MKPolyline(coordinates: simplifiedPoints, count: simplifiedPoints.count)
        }
        
        return polyline
    }
    
    // MARK: - Memory Management
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Cancel ongoing operations for better memory management
        searchTimer?.invalidate()
        currentSearchTask?.cancel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Clear search results cache on memory pressure
        if searchResults.count > 5 {
            searchResults = Array(searchResults.prefix(5))
            resultsTableView.reloadData()
        }
        
        // Clear map overlays if not actively being used
        if destinationCoordinate == nil {
            mapView.removeOverlays(mapView.overlays)
        }
    }
    
}
