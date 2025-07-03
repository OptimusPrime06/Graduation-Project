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

        
        // Configure results table
        resultsTableView.translatesAutoresizingMaskIntoConstraints = false
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.isHidden = true
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Add views
        view.addSubview(searchField)
        view.addSubview(searchIconButton)
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
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 1000
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let destination = destinationCoordinate else { return }
        showRoute(to: destination)
    }
}

extension MapViewController {
    @objc func searchButtonTapped() {
        if let query = searchField.text, !query.isEmpty {
            performSearch(query: query)
        }
    }
    
    @objc func searchTextChanged() {
        searchCompleter.queryFragment = searchField.text ?? ""
        buttonBottomToViewConstraint.isActive = false
        buttonBottomToRouteInfoConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
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
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .automobile
        
        MKDirections(request: request).calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first else {
                self?.showAlert(title: "Route Error", message: "Unable to calculate route.")
                return
            }
            
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            self.displayDistanceAndETA(for: route)
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
        searchResults = completer.results
        resultsTableView.reloadData()
        resultsTableView.isHidden = searchResults.isEmpty
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Completer error: \(error.localizedDescription)")
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
}

//MARK: - Preview

//#if DEBUG
//#Preview("Map View"){
//    MapViewController()
//}
//#endif
