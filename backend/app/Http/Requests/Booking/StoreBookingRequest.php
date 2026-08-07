<?php

namespace App\Http\Requests\Booking;

use Illuminate\Foundation\Http\FormRequest;

class StoreBookingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role === 'CUSTOMER';
    }

    public function rules(): array
    {
        return [
            'service_id' => [
                'required',
                'integer',
                'exists:services,id',
            ],

            'booking_date' => [
                'required',
                'date',
                'after_or_equal:today',
            ],

            'booking_time' => [
                'required',
                'date_format:H:i',
            ],

            'quantity' => [
                'nullable',
                'integer',
                'min:1',
                'max:10',
            ],

            'customer_name' => [
                'required',
                'string',
                'min:2',
                'max:100',
            ],

            'customer_phone' => [
                'required',
                'string',
                'regex:/^(0|\+84)[0-9]{9,10}$/',
            ],

            'service_address' => [
                'required',
                'string',
                'min:5',
                'max:255',
            ],

            'note' => [
                'nullable',
                'string',
                'max:1000',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'service_id.required' => 'Dịch vụ là bắt buộc.',
            'service_id.exists' => 'Dịch vụ không tồn tại.',

            'booking_date.required' => 'Ngày đặt dịch vụ là bắt buộc.',
            'booking_date.after_or_equal' =>
                'Ngày đặt dịch vụ không được ở trong quá khứ.',

            'booking_time.required' => 'Giờ đặt dịch vụ là bắt buộc.',
            'booking_time.date_format' =>
                'Giờ đặt dịch vụ phải có định dạng HH:mm.',

            'customer_name.required' =>
                'Tên người nhận dịch vụ là bắt buộc.',

            'customer_phone.required' =>
                'Số điện thoại là bắt buộc.',

            'customer_phone.regex' =>
                'Số điện thoại không đúng định dạng.',

            'service_address.required' =>
                'Địa chỉ thực hiện dịch vụ là bắt buộc.',
        ];
    }
}