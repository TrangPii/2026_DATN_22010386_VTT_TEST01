<?php

namespace App\Http\Requests\Service;

use Illuminate\Foundation\Http\FormRequest;

class UpdateServiceStatusRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'status' => [
                'required',
                'string',
                'in:ACTIVE,INACTIVE',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'status.required' => 'Trạng thái dịch vụ là bắt buộc.',
            'status.in' =>
                'Trạng thái dịch vụ chỉ có thể là ACTIVE hoặc INACTIVE.',
        ];
    }
}