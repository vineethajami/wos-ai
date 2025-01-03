
#include "utils.h"

#define DX_C_ASSERT(cond)      typedef CHAR __C_ASSERT__[(cond)?1:-1]

DEFINE_GUID(DXCORE_ADAPTER_ATTRIBUTE_D3D12_GENERIC_ML, 0xb71b0d41, 0x1088, 0x422f, 0xa2, 0x7c, 0x2, 0x50, 0xb7, 0xd3, 0xa9, 0x88);
DEFINE_GUID(GUID_NORMALIZATION, 0xe7ab4322, 0xd08d, 0x4683, 0xb6, 0x9a, 0xc6, 0xa4, 0xfb, 0x41, 0x0f, 0x6d);

struct DriverVersion
{
    union
    {
        struct
        {
            uint16_t d;
            uint16_t c;
            uint16_t b;
            uint16_t a;
        } parts;
        uint64_t value;
    };

    DriverVersion() = default;

    explicit DriverVersion(uint64_t value)
        : value(value)
    {
    }

    DriverVersion(uint16_t a, uint16_t b, uint16_t c, uint16_t d)
    {
        parts.a = a;
        parts.b = b;
        parts.c = c;
        parts.d = d;
    }
};

enum D3D_FEATURE_LEVEL_INTERNAL
{
    D3D_FEATURE_LEVEL_INTERNAL_1_0_GENERIC = 0x100,
    D3D_FEATURE_LEVEL_INTERNAL_1_0_CORE = 0x1000,
};

int bpFunc()
{
    HRESULT hr = S_OK;
    IDXCoreAdapterFactory* pFactory = nullptr;
    IDXCoreAdapterList* pAdapterList = nullptr;
    IDXCoreAdapter* pAdapter = nullptr;
    int32_t dmlAdapter = -1;
    int32_t npuAvailable = -1;

    // Create a DXCore Factory instance
    hr = DXCoreCreateAdapterFactory(&pFactory);
    if (FAILED(hr)) {
        std::cerr << "Failed to create DXCore Factory." << std::endl;
        return 1;
    }

    // Enumerate adapters
    const GUID filter[] = { DXCORE_ADAPTER_ATTRIBUTE_D3D12_GENERIC_ML };
    hr = pFactory->CreateAdapterList(1, filter, IID_PPV_ARGS(&pAdapterList));
    if (FAILED(hr)) {
        std::cerr << "Failed to create adapter list." << std::endl;
        pFactory->Release();
        return 1;
    }

    // Get the number of adapters
    size_t adapterCount = pAdapterList->GetAdapterCount();

    std::cout << "Number of Adapters: " << adapterCount << std::endl;
    //numAdaptors = adapterCount;
    // Loop through all adapters
    for (size_t i = 0; i < adapterCount; ++i) {
        pAdapterList->GetAdapter((uint32_t)i, IID_PPV_ARGS(&pAdapter));

        // Get adapter properties
        DXCoreHardwareIDParts hardwareId;
        pAdapter->GetProperty(DXCoreAdapterProperty::HardwareID, &hardwareId);
        std::cout << "\nAdapter " << i << ": Vendor ID = " << hardwareId.vendorID
            << ", Device ID = " << hardwareId.deviceID << std::endl;

        if (hardwareId.deviceID == 1093682224)
            npuAvailable = 1;


        size_t propSize = 0;
        pAdapter->GetPropertySize(DXCoreAdapterProperty::DriverDescription, &propSize);
        std::vector<char> driver_description(propSize);
        std::cout << "prop size: " << propSize << std::endl;
        pAdapter->GetProperty(DXCoreAdapterProperty::DriverDescription, propSize, driver_description.data());
        std::string name;
        name.assign(driver_description.begin(), driver_description.end());
        std::cout << "Desc: " << name << std::endl;

        LARGE_INTEGER driverVersion;
        pAdapter->GetProperty(DXCoreAdapterProperty::DriverVersion, sizeof(driverVersion), &driverVersion);
        DriverVersion ver(driverVersion.QuadPart);

        std::cout << "Version:" << ver.parts.a << "." << ver.parts.b << "." << ver.parts.c << "." << ver.parts.d << std::endl;

        if (ver.parts.a == 4000)
            dmlAdapter = (uint32_t)i;

        pAdapter->Release();
    }
    pAdapterList->Release();
    pFactory->Release();

    //system("pause");

    return npuAvailable;
}