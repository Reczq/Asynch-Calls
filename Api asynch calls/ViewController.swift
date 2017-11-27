import UIKit

class ViewController: UIViewController {

    let systemQueue = DispatchQueue.global(qos: .background)
    let group = DispatchGroup()

    var models = Model()

    override func viewDidLoad() {
        super.viewDidLoad()

        startRequests()
    }

    func startRequests() {
        systemQueue.async {
            self.group.enter()
            self.asyncFunctionIP(with: "https://httpbin.org/ip") { [weak self] model in
                if let origin = model.origin {
                    self?.models.origin = origin
                }
                self?.group.leave()
            }

            self.group.enter()
            self.asyncFunctionUUID(with: "https://httpbin.org/uuid", completion: { [weak self] model in
                if let uuid = model.uuid {
                    self?.models.uuid = uuid
                }
                self?.group.leave()
            })

            self.group.notify(queue: .main) { [weak self] in
                if let ip = self?.models.origin, let uuid = self?.models.uuid {
                    self?.createAlert(title: ip, message: uuid)
                }
            }
        }
    }

    private func asyncFunctionIP(with url: String, completion: @escaping (Model) -> ()) {

        guard let url = URL(string: url) else { return }
        let session = URLSession.shared

        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decode = try JSONDecoder().decode(Model.self, from: data)
                completion(decode)
            } catch let error {
                print("error: \(error)")
            }
        }
        task.resume()
    }


    private func asyncFunctionUUID(with url: String, completion: @escaping (Model) -> ()) {

        guard let url = URL(string: url) else { return }
        let session = URLSession.shared

        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decode = try JSONDecoder().decode(Model.self, from: data)
                completion(decode)
            } catch let error {
                print("error: \(error)")
            }
        }
        task.resume()
    }

    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }
}
