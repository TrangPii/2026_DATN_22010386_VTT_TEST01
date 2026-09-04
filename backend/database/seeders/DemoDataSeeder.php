<?php

namespace Database\Seeders;

use App\Models\Booking;
use App\Models\BookingStatusHistory;
use App\Models\ProviderProfile;
use App\Models\Review;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function (): void {
            $users = $this->seedUsers();
            $this->seedProviderProfiles($users);

            $categories = $this->seedCategories();
            $services = $this->seedServices($users, $categories);

            $this->seedBookingsAndReviews($users, $services);
        });
    }

    /**
     * Tạo tài khoản demo.
     *
     * @return array<string, User>
     */
    private function seedUsers(): array
    {
        $password = Hash::make('Password@123');

        return [
            'admin' => User::updateOrCreate(
                ['email' => 'admin@smartservice.test'],
                [
                    'name' => 'Quản trị viên',
                    'phone' => '0900000001',
                    'password' => $password,
                    'role' => 'ADMIN',
                    'status' => 'ACTIVE',
                    'email_verified_at' => now(),
                ]
            ),

            'customer1' => User::updateOrCreate(
                ['email' => 'customer1@smartservice.test'],
                [
                    'name' => 'Nguyễn Minh Anh',
                    'phone' => '0900000002',
                    'password' => $password,
                    'role' => 'CUSTOMER',
                    'status' => 'ACTIVE',
                    'email_verified_at' => now(),
                ]
            ),

            'customer2' => User::updateOrCreate(
                ['email' => 'customer2@smartservice.test'],
                [
                    'name' => 'Trần Thu Hà',
                    'phone' => '0900000003',
                    'password' => $password,
                    'role' => 'CUSTOMER',
                    'status' => 'ACTIVE',
                    'email_verified_at' => now(),
                ]
            ),

            'provider1' => User::updateOrCreate(
                ['email' => 'provider1@smartservice.test'],
                [
                    'name' => 'Lê Văn Hùng',
                    'phone' => '0900000004',
                    'password' => $password,
                    'role' => 'CUSTOMER',
                    'status' => 'ACTIVE',
                    'email_verified_at' => now(),
                ]
            ),

            'provider2' => User::updateOrCreate(
                ['email' => 'provider2@smartservice.test'],
                [
                    'name' => 'Phạm Quốc Bảo',
                    'phone' => '0900000005',
                    'password' => $password,
                    'role' => 'CUSTOMER',
                    'status' => 'ACTIVE',
                    'email_verified_at' => now(),
                ]
            ),

            'provider3' => User::updateOrCreate(
                ['email' => 'provider3@smartservice.test'],
                [
                    'name' => 'Đỗ Ngọc Lan',
                    'phone' => '0900000006',
                    'password' => $password,
                    'role' => 'CUSTOMER',
                    'status' => 'ACTIVE',
                    'email_verified_at' => now(),
                ]
            ),
        ];
    }

    /**
     * @param array<string, User> $users
     */
    private function seedProviderProfiles(array $users): void
    {
        ProviderProfile::updateOrCreate(
            ['user_id' => $users['provider1']->id],
            [
                'business_name' => 'Dịch vụ Gia đình Hùng Phát',
                'description' => 'Chuyên vệ sinh nhà cửa và sửa chữa điện nước.',
                'address' => 'Cầu Giấy, Hà Nội',
                'identity_number' => '001090000001',
                'experience_years' => 5,
                'average_rating' => 5.00,
                'total_reviews' => 1,
                'verification_status' => 'APPROVED',
                'verified_at' => now(),
            ]
        );

        ProviderProfile::updateOrCreate(
            ['user_id' => $users['provider2']->id],
            [
                'business_name' => 'Điện lạnh Bảo An',
                'description' => 'Bảo dưỡng và sửa chữa thiết bị điện lạnh tại nhà.',
                'address' => 'Nam Từ Liêm, Hà Nội',
                'identity_number' => '001090000002',
                'experience_years' => 4,
                'average_rating' => 0,
                'total_reviews' => 0,
                'verification_status' => 'APPROVED',
                'verified_at' => now(),
            ]
        );

        ProviderProfile::updateOrCreate(
            ['user_id' => $users['provider3']->id],
            [
                'business_name' => 'Chăm sóc sắc đẹp Ngọc Lan',
                'description' => 'Dịch vụ làm đẹp và chăm sóc cá nhân tại nhà.',
                'address' => 'Thanh Xuân, Hà Nội',
                'identity_number' => '001090000003',
                'experience_years' => 3,
                'average_rating' => 0,
                'total_reviews' => 0,
                'verification_status' => 'APPROVED',
                'verified_at' => now(),
            ]
        );
    }

    /**
     * @return array<string, ServiceCategory>
     */
    private function seedCategories(): array
    {
        $data = [
            'cleaning' => [
                'name' => 'Vệ sinh nhà cửa',
                'description' => 'Các dịch vụ vệ sinh nhà ở và căn hộ.',
            ],
            'repair' => [
                'name' => 'Sửa chữa gia đình',
                'description' => 'Sửa chữa điện, nước và thiết bị trong nhà.',
            ],
            'beauty' => [
                'name' => 'Làm đẹp tại nhà',
                'description' => 'Các dịch vụ chăm sóc cá nhân và làm đẹp.',
            ],
            'education' => [
                'name' => 'Giáo dục tại nhà',
                'description' => 'Gia sư và hỗ trợ học tập tại nhà.',
            ],
        ];

        $categories = [];

        foreach ($data as $key => $categoryData) {
            $categories[$key] = ServiceCategory::updateOrCreate(
                ['slug' => Str::slug($categoryData['name'])],
                [
                    ...$categoryData,
                    'status' => 'ACTIVE',
                ]
            );
        }

        return $categories;
    }

    /**
     * @param array<string, User> $users
     * @param array<string, ServiceCategory> $categories
     *
     * @return array<string, Service>
     */
    private function seedServices(
        array $users,
        array $categories
    ): array {
        $serviceData = [
            'apartment_cleaning' => [
                'category' => 'cleaning',
                'provider' => 'provider1',
                'name' => 'Vệ sinh căn hộ',
                'description' => 'Vệ sinh tổng thể căn hộ có diện tích dưới 80 m².',
                'price' => 350000,
                'price_unit' => 'lần',
                'estimated_duration_minutes' => 180,
            ],
            'hourly_cleaning' => [
                'category' => 'cleaning',
                'provider' => 'provider1',
                'name' => 'Vệ sinh theo giờ',
                'description' => 'Nhân viên vệ sinh nhà cửa theo thời lượng yêu cầu.',
                'price' => 100000,
                'price_unit' => 'giờ',
                'estimated_duration_minutes' => 60,
            ],
            'electrical_repair' => [
                'category' => 'repair',
                'provider' => 'provider1',
                'name' => 'Sửa chữa điện dân dụng',
                'description' => 'Kiểm tra và xử lý các sự cố điện cơ bản trong nhà.',
                'price' => 200000,
                'price_unit' => 'lần',
                'estimated_duration_minutes' => 90,
            ],
            'plumbing_repair' => [
                'category' => 'repair',
                'provider' => 'provider1',
                'name' => 'Sửa chữa đường nước',
                'description' => 'Xử lý rò rỉ, tắc nghẽn và hỏng đường nước.',
                'price' => 250000,
                'price_unit' => 'lần',
                'estimated_duration_minutes' => 120,
            ],
            'air_conditioner_cleaning' => [
                'category' => 'repair',
                'provider' => 'provider2',
                'name' => 'Vệ sinh điều hòa',
                'description' => 'Vệ sinh và kiểm tra hoạt động của điều hòa.',
                'price' => 180000,
                'price_unit' => 'máy',
                'estimated_duration_minutes' => 60,
            ],
            'air_conditioner_repair' => [
                'category' => 'repair',
                'provider' => 'provider2',
                'name' => 'Sửa chữa điều hòa',
                'description' => 'Kiểm tra và sửa chữa lỗi điều hòa tại nhà.',
                'price' => 300000,
                'price_unit' => 'lần',
                'estimated_duration_minutes' => 120,
            ],
            'home_nail' => [
                'category' => 'beauty',
                'provider' => 'provider3',
                'name' => 'Làm móng tại nhà',
                'description' => 'Chăm sóc và làm móng cơ bản tại nhà.',
                'price' => 220000,
                'price_unit' => 'lần',
                'estimated_duration_minutes' => 90,
            ],
            'home_hair_wash' => [
                'category' => 'beauty',
                'provider' => 'provider3',
                'name' => 'Gội đầu dưỡng sinh tại nhà',
                'description' => 'Gội đầu và massage thư giãn tại nhà.',
                'price' => 180000,
                'price_unit' => 'lần',
                'estimated_duration_minutes' => 60,
            ],
        ];

        $services = [];

        foreach ($serviceData as $key => $data) {
            $category = $categories[$data['category']];
            $provider = $users[$data['provider']];
            $slug = Str::slug($data['name']);

            $services[$key] = Service::updateOrCreate(
                [
                    'provider_id' => $provider->id,
                    'slug' => $slug,
                ],
                [
                    'category_id' => $category->id,
                    'name' => $data['name'],
                    'description' => $data['description'],
                    'price' => $data['price'],
                    'price_unit' => $data['price_unit'],
                    'estimated_duration_minutes' =>
                        $data['estimated_duration_minutes'],
                    'status' => 'ACTIVE',
                ]
            );
        }

        return $services;
    }

    /**
     * @param array<string, User> $users
     * @param array<string, Service> $services
     */
    private function seedBookingsAndReviews(
        array $users,
        array $services
    ): void {
        $pendingBooking = $this->createBooking(
            bookingCode: 'BK-DEMO-001',
            customer: $users['customer1'],
            service: $services['air_conditioner_cleaning'],
            bookingDate: now()->addDays(2)->toDateString(),
            bookingTime: '09:00:00',
            address: '123 Nguyễn Trãi, Thanh Xuân, Hà Nội',
            status: 'PENDING'
        );

        $this->createStatusHistory(
            booking: $pendingBooking,
            changedBy: $users['customer1'],
            oldStatus: null,
            newStatus: 'PENDING',
            note: 'Khách hàng tạo yêu cầu đặt dịch vụ.'
        );

        $acceptedBooking = $this->createBooking(
            bookingCode: 'BK-DEMO-002',
            customer: $users['customer2'],
            service: $services['apartment_cleaning'],
            bookingDate: now()->addDay()->toDateString(),
            bookingTime: '14:00:00',
            address: '25 Trần Duy Hưng, Cầu Giấy, Hà Nội',
            status: 'ACCEPTED',
            acceptedAt: now()
        );

        $this->createStatusHistory(
            booking: $acceptedBooking,
            changedBy: $users['customer2'],
            oldStatus: null,
            newStatus: 'PENDING',
            note: 'Khách hàng tạo yêu cầu đặt dịch vụ.'
        );

        $this->createStatusHistory(
            booking: $acceptedBooking,
            changedBy: $acceptedBooking->provider,
            oldStatus: 'PENDING',
            newStatus: 'ACCEPTED',
            note: 'Nhà cung cấp đã chấp nhận yêu cầu.'
        );

        $inProgressBooking = $this->createBooking(
            bookingCode: 'BK-DEMO-003',
            customer: $users['customer1'],
            service: $services['home_nail'],
            bookingDate: now()->toDateString(),
            bookingTime: '16:00:00',
            address: '80 Láng Hạ, Đống Đa, Hà Nội',
            status: 'IN_PROGRESS',
            acceptedAt: now()->subHour(),
            startedAt: now()
        );

        $this->createStatusHistory(
            booking: $inProgressBooking,
            changedBy: $users['customer1'],
            oldStatus: null,
            newStatus: 'PENDING',
            note: 'Khách hàng tạo yêu cầu đặt dịch vụ.'
        );

        $this->createStatusHistory(
            booking: $inProgressBooking,
            changedBy: $inProgressBooking->provider,
            oldStatus: 'PENDING',
            newStatus: 'ACCEPTED',
            note: 'Nhà cung cấp đã chấp nhận yêu cầu.'
        );

        $this->createStatusHistory(
            booking: $inProgressBooking,
            changedBy: $inProgressBooking->provider,
            oldStatus: 'ACCEPTED',
            newStatus: 'IN_PROGRESS',
            note: 'Nhà cung cấp bắt đầu thực hiện dịch vụ.'
        );

        $completedBooking = $this->createBooking(
            bookingCode: 'BK-DEMO-004',
            customer: $users['customer2'],
            service: $services['hourly_cleaning'],
            bookingDate: now()->subDay()->toDateString(),
            bookingTime: '10:00:00',
            address: '12 Duy Tân, Cầu Giấy, Hà Nội',
            status: 'COMPLETED',
            acceptedAt: now()->subDay()->setTime(9, 30),
            startedAt: now()->subDay()->setTime(10, 0),
            completedAt: now()->subDay()->setTime(12, 0)
        );

        $this->createStatusHistory(
            booking: $completedBooking,
            changedBy: $users['customer2'],
            oldStatus: null,
            newStatus: 'PENDING',
            note: 'Khách hàng tạo yêu cầu đặt dịch vụ.'
        );

        $this->createStatusHistory(
            booking: $completedBooking,
            changedBy: $completedBooking->provider,
            oldStatus: 'PENDING',
            newStatus: 'ACCEPTED',
            note: 'Nhà cung cấp đã chấp nhận yêu cầu.'
        );

        $this->createStatusHistory(
            booking: $completedBooking,
            changedBy: $completedBooking->provider,
            oldStatus: 'ACCEPTED',
            newStatus: 'IN_PROGRESS',
            note: 'Nhà cung cấp bắt đầu thực hiện dịch vụ.'
        );

        $this->createStatusHistory(
            booking: $completedBooking,
            changedBy: $completedBooking->provider,
            oldStatus: 'IN_PROGRESS',
            newStatus: 'COMPLETED',
            note: 'Dịch vụ đã hoàn thành.'
        );

        Review::updateOrCreate(
            ['booking_id' => $completedBooking->id],
            [
                'customer_id' => $completedBooking->customer_id,
                'provider_id' => $completedBooking->provider_id,
                'rating' => 5,
                'comment' => 'Nhân viên nhiệt tình, hoàn thành đúng giờ.',
                'status' => 'VISIBLE',
            ]
        );
    }

    private function createBooking(
        string $bookingCode,
        User $customer,
        Service $service,
        string $bookingDate,
        string $bookingTime,
        string $address,
        string $status,
        mixed $acceptedAt = null,
        mixed $startedAt = null,
        mixed $completedAt = null
    ): Booking {
        return Booking::updateOrCreate(
            ['booking_code' => $bookingCode],
            [
                'customer_id' => $customer->id,
                'provider_id' => $service->provider_id,
                'service_id' => $service->id,
                'service_name' => $service->name,
                'unit_price' => $service->price,
                'quantity' => 1,
                'total_amount' => $service->price,
                'booking_date' => $bookingDate,
                'booking_time' => $bookingTime,
                'customer_name' => $customer->name,
                'customer_phone' => $customer->phone,
                'service_address' => $address,
                'note' => null,
                'status' => $status,
                'accepted_at' => $acceptedAt,
                'started_at' => $startedAt,
                'completed_at' => $completedAt,
            ]
        );
    }

    private function createStatusHistory(
        Booking $booking,
        User $changedBy,
        ?string $oldStatus,
        string $newStatus,
        ?string $note
    ): void {
        BookingStatusHistory::firstOrCreate(
            [
                'booking_id' => $booking->id,
                'old_status' => $oldStatus,
                'new_status' => $newStatus,
            ],
            [
                'changed_by' => $changedBy->id,
                'note' => $note,
            ]
        );
    }
}