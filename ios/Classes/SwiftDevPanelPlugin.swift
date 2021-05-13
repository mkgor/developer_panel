import Flutter
import UIKit

public class SwiftDevPanelPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dev_panel", binaryMessenger: registrar.messenger())
    let instance = SwiftDevPanelPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "getPerformance":
             // Getting memory usage
            let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
            let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
            var info = task_vm_info_data_t()
            var count = TASK_VM_INFO_COUNT
            let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
                infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                    task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
                }
            }
            guard
                kr == KERN_SUCCESS,
                count >= TASK_VM_INFO_REV1_COUNT
            else { return; }

            let usedBytes = Float(info.phys_footprint)
            let totalMemory = ProcessInfo.processInfo.physicalMemory


            // Getting cpu usage

            let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride/MemoryLayout<integer_t>.stride
            var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
            var load = host_cpu_load_info()

            let cpuLoadResult = withUnsafeMutablePointer(to: &load) {
                $0.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
                    host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
                }
            }
            if cpuLoadResult != KERN_SUCCESS{
                print("Error  - \(#file): \(#function) - kern_result_t = \(result)")
                return;
            }

            let totalTicks = Double(load.cpu_ticks.0) + Double(load.cpu_ticks.1) + Double(load.cpu_ticks.2) + Double(load.cpu_ticks.3)

            let sys = String(Double(load.cpu_ticks.1) / totalTicks * 100.0)
            let usr = String(Double(load.cpu_ticks.0) / totalTicks * 100.0)

            result("\(usedBytes)/\(totalMemory)/\(usr)")
        default:
            result(0)
    }
  }
}
