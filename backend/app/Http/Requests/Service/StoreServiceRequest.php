<?php

namespace App\Http\Requests\Service;

use Illuminate\Foundation\Http\FormRequest;

class StoreServiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id' => [
                'required',
                'integer',
                'exists:service_categories,id',
            ],

            'name' => [
                'required',
                'string',
                'min:3',
                'max:255',
            ],

            'description' => [
                'nullable',
                'string',
                'max:3000',
            ],

            'price' => [
                'required',
                'numeric',
                'min:0',
                'max:9999999999999.99',
            ],

            'price_unit' => [
                'required',
                'string',
                'max:50',
            ],

            'estimated_duration_minutes' => [
                'nullable',
                'integer',
                'min:1',
                'max:1440',
            ],

            'image' => [
                'nullable',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:4096',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'category_id.required' => 'Danh mục dịch vụ là bắt buộc.',
            'category_id.exists' => 'Danh mục dịch vụ không tồn tại.',

            'name.required' => 'Tên dịch vụ là bắt buộc.',
            'name.min' => 'Tên dịch vụ phải có ít nhất 3 ký tự.',

            'price.required' => 'Giá dịch vụ là bắt buộc.',
            'price.numeric' => 'Giá dịch vụ không hợp lệ.',
            'price.min' => 'Giá dịch vụ không được nhỏ hơn 0.',

            'price_unit.required' => 'Đơn vị tính giá là bắt buộc.',

            'estimated_duration_minutes.min' =>
                'Thời gian dự kiến phải lớn hơn 0 phút.',

            'image.image' =>
                'Tệp tải lên phải là hình ảnh.',
            'image.mimes' =>
                'Ảnh chỉ hỗ trợ định dạng JPG, JPEG, PNG hoặc WEBP.',
            'image.max' =>
                'Dung lượng ảnh tối đa là 4 MB.',
        ];
    }
}