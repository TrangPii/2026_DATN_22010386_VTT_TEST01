<?php

namespace App\Http\Requests\Review;

use Illuminate\Foundation\Http\FormRequest;

class StoreReviewRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role === 'CUSTOMER';
    }

    public function rules(): array
    {
        return [
            'rating' => [
                'required',
                'integer',
                'between:1,5',
            ],

            'comment' => [
                'nullable',
                'string',
                'max:1000',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'rating.required' => 'Vui lòng chọn số sao đánh giá.',
            'rating.integer' => 'Điểm đánh giá phải là số nguyên.',
            'rating.between' => 'Điểm đánh giá phải từ 1 đến 5 sao.',
            'comment.max' => 'Nội dung đánh giá không được vượt quá 1000 ký tự.',
        ];
    }
}