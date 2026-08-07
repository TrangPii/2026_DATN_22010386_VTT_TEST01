<?php

namespace App\Http\Requests\Provider;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProviderProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role === 'PROVIDER';
    }

    public function rules(): array
    {
        return [
            'business_name' => [
                'sometimes',
                'required',
                'string',
                'min:2',
                'max:255',
            ],

            'description' => [
                'sometimes',
                'nullable',
                'string',
                'max:3000',
            ],

            'address' => [
                'sometimes',
                'nullable',
                'string',
                'max:255',
            ],

            'identity_number' => [
                'sometimes',
                'nullable',
                'string',
                'max:30',
            ],

            'experience_years' => [
                'sometimes',
                'required',
                'integer',
                'min:0',
                'max:80',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'business_name.required' =>
                'Tên nhà cung cấp là bắt buộc.',

            'business_name.min' =>
                'Tên nhà cung cấp phải có ít nhất 2 ký tự.',

            'experience_years.integer' =>
                'Số năm kinh nghiệm phải là số nguyên.',

            'experience_years.min' =>
                'Số năm kinh nghiệm không được nhỏ hơn 0.',
        ];
    }
}